module Netzke
  module GridPanelExtras
    module JsBuilder
      def self.included(base)
        base.extend ClassMethods
      end

      def js_config
        res = super
        res.merge!(:columns => columns)
        res.merge!(:data_class_name => config[:data_class_name])
        res
      end
  
      def js_ext_config
        super.merge({
          :rows_per_page => persistent_config["rows_per_page"] ||= config[:ext_config][:rows_per_page]
        })
      end
      
      module ClassMethods

        def js_base_class 
          'Ext.grid.EditorGridPanel'
        end

        def js_default_config
          super.merge({
            :store            => "ds".l,
            :cm               => "cm".l,
            :sel_model        => "new Ext.grid.RowSelectionModel()".l,
            :auto_scroll      => true,
            :click_to_edit    => 2,
            :track_mouse_over => true,
            :plugins          => "plugins".l,
            :load_mask        => true,
      
            #custom configs
            :auto_load_data   => true
          })
        end
  
        def js_before_constructor
          <<-JS
          var plugins = [];
          if (!config.columns) {this.feedback('No columns defined for grid '+config.id);}
          this.recordConfig = [];
          Ext.each(config.columns, function(column){this.recordConfig.push({name:column.name});}, this);
          this.Row = Ext.data.Record.create(this.recordConfig);

          var ds = new Ext.data.Store({
              proxy: this.proxy = new Ext.data.HttpProxy({url:config.interface.getData}),
              reader: new Ext.data.ArrayReader({root: "data", totalProperty: "total", successProperty: "succes", id:0}, this.Row),
              remoteSort: true,
              listeners:{'loadexception':{
                fn:this.loadExceptionHandler,
                scope:this
              }}
          });
    
          this.cmConfig = [];
          Ext.each(config.columns, function(c){
            var extConfig;
            try{
              extConfig = Ext.decode(c.extConfig);
            }
            catch(err){
              extConfig = {};
            }
            delete(c.extConfig);
        
            if (c.editor == 'checkbox') {
              var plugin = new Ext.grid.CheckColumn(Ext.apply({
          			header    : c.label || c.name,
          			dataIndex : c.name,
          			disabled  : c.readOnly,
          			hidden    : c.hidden,
          			width     : c.width
              }, extConfig));

              plugins.push(plugin);
              this.cmConfig.push(plugin);
          
            } else {
              // editor is created by xtype stored in c.editor
              var editor = (c.readOnly || !config.permissions.update) ? null : Ext.ComponentMgr.create({
                xtype:c.editor, 
                parentConfig:config, 
                fieldConfig:c, 
                selectOnFocus:true
              });
              
              var renderer = Ext.netzke.renderer(c.renderer);

              this.cmConfig.push(Ext.apply({
                header    : c.label || c.name,
                dataIndex : c.name,
                hidden    : c.hidden,
                width     : c.width,
                editor    : editor,
                renderer  : renderer,
                sortable  : true
              }, extConfig));
            }

          }, this);

          var cm = new Ext.grid.ColumnModel(this.cmConfig);
          cm.on('hiddenchange', this.onColumnHiddenChange, this);
    
          // Filters
          if (config.enableColumnFilters) {
            var filters = [];
            Ext.each(config.columns, function(c){
              filters.push({type:Ext.netzke.filterMap[c.editor], dataIndex:c.name});
            });
            var gridFilters = new Ext.grid.GridFilters({filters:filters});
            plugins.push(gridFilters);
          }
          
          config.bbar = (config.rowsPerPage) ? new Ext.PagingToolbar({
            pageSize : config.rowsPerPage, 
            items : config.bbar ? ["-", config.bbar] : [], 
            store : ds, 
            emptyMsg:'Empty'}) : config.bbar
    
          JS
        end
  
        def js_listeners
          super.merge({
            :columnresize => {:fn => "this.onColumnResize".l, :scope => this},
            :columnmove   => {:fn => "this.onColumnMove".l, :scope => this}
          })
        end
  
        def js_extend_properties
          {
            :on_widget_load => <<-JS.l,
              function(){
                // auto-load
                if (this.initialConfig.autoLoadData) {
                  // if we have a paging toolbar, load the first page
                  if (this.getBottomToolbar() && this.getBottomToolbar().changePage) {this.getBottomToolbar().changePage(0);} else {this.store.load();}
                }
              }
            JS
      
            :load_exception_handler => <<-JS.l,
            function(proxy, options, response, error){
              if (response.status == 200 && (responseObject = Ext.decode(response.responseText)) && responseObject.flash){
                this.feedback(responseObject.flash);
              } else {
                if (error){
                  this.feedback(error.message);
                } else {
                  this.feedback(response.statusText);
                }  
              }
            }        
            JS
    
            :add => <<-JS.l,
              function(){
                var rowConfig = {};
                Ext.each(this.initialConfig.columns, function(c){
                  rowConfig[c.name] = c.defaultValue || ''; // FIXME: if the user is happy with all the defaults, the record won't be 'dirty'
                }, this);
          
                var r = new this.Row(rowConfig); // TODO: add default values
                r.is_new = true; // to distinguish new records
                r.set('id', r.id); // otherwise later r.get('id') returns empty string
                this.stopEditing();
                this.store.add(r);
                this.tryStartEditing(this.store.indexOf(r));
              }
            JS
    
            :edit => <<-JS.l,
              function(){
                var row = this.getSelectionModel().getSelected();
                if (row){
                  this.tryStartEditing(this.store.indexOf(row));
                }
              }
            JS
    
            # try editing the first editable (not hidden, not read-only) sell
            :try_start_editing => <<-JS.l,
              function(row){
                if (row === null) {return;}
                var editableColumns = this.getColumnModel().getColumnsBy(function(columnConfig, index){
                  return !columnConfig.hidden && !!columnConfig.editor;
                });
                var firstEditableColumn = editableColumns[0];
                if (firstEditableColumn){
                  this.startEditing(row, firstEditableColumn.id);
                }
              }
            JS

            :delete => <<-JS.l,
              function() {
                if (this.getSelectionModel().hasSelection()){
                  Ext.Msg.confirm('Confirm', 'Are you sure?', function(btn){
                    if (btn == 'yes') {
                      var records = [];
                      this.getSelectionModel().each(function(r){
                        records.push(r.get('id'));
                      }, this);
                      Ext.Ajax.request({
                        url: this.initialConfig.interface.deleteData,
                        params: {records: Ext.encode(records)},
                        success:function(r){ 
                          var m = Ext.decode(r.responseText);
                          this.store.reload();
                          this.feedback(m.flash);
                        },
                        scope:this
                      });
                    }
                  }, this);
                }
              }
            JS
            :apply => <<-JS.l,
              function(){
                var newRecords = [];
                var updatedRecords = [];

                Ext.each(this.store.getModifiedRecords(),
                  function(r) {
                    if (r.is_new) {
                      newRecords.push(Ext.apply(r.getChanges(), {id:r.get('id')}));
                    } else {
                      updatedRecords.push(Ext.apply(r.getChanges(), {id:r.get('id')}));
                    }
                  }, 
                this);
          
                if (newRecords.length > 0 || updatedRecords.length > 0) {
                  var params = {};

                  if (newRecords.length > 0) {
                    params.created_records = Ext.encode(newRecords);
                  }
                  
                  if (updatedRecords.length > 0) {
                    params.updated_records = Ext.encode(updatedRecords);
                  }
                  
                  if (this.store.baseParams !== {}) {
                    params.base_params = Ext.encode(this.store.baseParams);
                  }
                  
                  Ext.Ajax.request({
                    url:this.initialConfig.interface.postData,
                    params: params,
                    success:function(response){
                      var m = Ext.decode(response.responseText);
                      if (m.success) {
                        // commit those rows that have successfully been updated/created
                        var modRecords = [].concat(this.store.getModifiedRecords()); // there must be a better way to clone an array...
                        Ext.each(modRecords, function(r){
                          var idsToSearch = r.is_new ? m.modRecordIds.create : m.modRecordIds.update;
                          if (idsToSearch.indexOf(r.id) >= 0) {r.commit();}
                        });

                        // reload the grid only when there were no errors
                        // (we need to reload because of filtering, sorting, etc)
                        if (this.store.getModifiedRecords().length === 0){
                          this.store.reload();
                        }

                        this.feedback(m.flash);
                      } else {
                        this.feedback(m.flash);
                      }
                    },
                    failure:function(response){
                      this.feedback('Bad response from server');
                    },
                    scope:this
                  });
                }
          
              }
            JS
   
            :refresh => <<-JS.l,
              function() {
                if (this.fireEvent('refresh', this) !== false) {this.store.reload();}
              }
            JS
      
            :on_column_resize => <<-JS.l,
              function(index, size){
                Ext.Ajax.request({
                  url:this.initialConfig.interface.resizeColumn,
                  params:{
                    index:index,
                    size:size
                  }
                });
              }
            JS
      
            :on_column_hidden_change => <<-JS.l,
              function(cm, index, hidden){
                Ext.Ajax.request({
                  url:this.initialConfig.interface.hideColumn,
                  params:{
                    index:index,
                    hidden:hidden
                  }
                });
              }
            JS
      
            :on_column_move => <<-JS.l
              function(oldIndex, newIndex){
                Ext.Ajax.request({
                  url:this.initialConfig.interface.moveColumn,
                  params:{
                    old_index:oldIndex,
                    new_index:newIndex
                  }
                });
              }
            JS
      
          }
        end
      end
    end
  end
end