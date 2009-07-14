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
        # logger.debug "!!! config[:widget].id_name: #{config[:widget].id_name.inspect}"
        res.merge!(:inline_data => get_data) if config[:load_inline_data]
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
            :track_mouse_over => true,
            :plugins          => "plugins".l,
            :load_mask        => true,

            #custom configs
            :auto_load_data   => false
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
              proxy: this.proxy = new Ext.data.HttpProxy({url:config.id+"__get_data"}),
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
            emptyMsg:'Empty'
          }) : config.bbar

          // Load data after the toolbar is bound to the store, which will provide for correct page number
          ds.loadData(config.inlineData);
    
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
    
            :load_store_data => <<-JS.l,
              function(data){
                // console.info(data);
                this.store.loadData(data);
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
                      this.deleteData({records: Ext.encode(records)});
                    }
                  }, this);
                }
              }
            JS

            # Called by the server side to update newly created records
            :update_new_records => <<-JS.l,
              function(records){
                this.updateRecords(records);
              }
            JS
            
            # Called by the server side to update modified records
            :update_mod_records => <<-JS.l,
              function(records){
                this.updateRecords(records, true);
              }
            JS
            
            # Updates modified or newly created records
            # Example of the records argument:
            #   {1098 => [1, 'value1', 'value2'], 1099 => [2, 'value1', 'value2']}
            :update_records => <<-JS.l,
              function(records, mod){
                if (!mod) {mod = false;}
                var modRecords = [].concat(this.store.getModifiedRecords()); // there must be a better way to clone an array...
                // replace arrays of data in the args object with Ext.data.Record objects
                for (var k in records){
                  records[k] = this.store.reader.readRecords([records[k]]).records[0];
                }
                
                // for each new record write the data returned by the server, and commit the record
                Ext.each(modRecords, function(r){
                  if (mod ^ r.is_new) {
                    var newData = records[r.get('id')];
                    for (var k in r.data){
                      r.set(k, newData.get(k));
                      r.commit();
                      r.is_new = false;
                    }
                  }
                });
                
                
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
                  
                  this.postData(params);
                }
          
              }
            JS
   
            :refresh => <<-JS.l,
              function() {
                if (this.fireEvent('refresh', this) !== false) {
                  this.store.reload();
                }
              }
            JS
      
            :on_column_resize => <<-JS.l,
              function(index, size){
                this.resizeColumn({
                  index:index,
                  size:size
                });
              }
            JS
      
            :on_column_hidden_change => <<-JS.l,
              function(cm, index, hidden){
                this.hideColumn({
                  index:index,
                  hidden:hidden
                });
              }
            JS
      
            :reorder_columns => <<-JS.l,
              function(columns){
                columnsInNewOrder = [];
                Ext.each(columns, function(c){
                  columnsInNewOrder.push({name:c});
                });
                newRecordType = Ext.data.Record.create(columnsInNewOrder);
                this.store.reader.recordType = newRecordType; // yes, recordType is a protected property, but that's the only way we can do it, and it seems to work
              }
            JS
      
            :on_column_move => <<-JS.l
              function(oldIndex, newIndex){
                this.moveColumn({
                  old_index:oldIndex,
                  new_index:newIndex
                });
              }
            JS
      
          }
        end
      end
    end
  end
end