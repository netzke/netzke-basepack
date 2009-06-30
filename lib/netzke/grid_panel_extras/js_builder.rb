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
                if (this.fireEvent('refresh', this) !== false) {
                  // this.store.reload();
                  this.getData();
                  // this.store.loadData([[1, "admin", "administrator", "b58460c3239a25858b88d2a746ab0ed95157fb7d7d7bf1b102cc39d230c6820879009552352556042ab2eb9289dc241b58a3a5ccf4c7730ffe5771fbaf17ba3d", "PE7dlrsCx2VT-cJOJ2Xe", "b01ad059b53808d9d348060578ab7a9e64bdf33255a37b549a23836582a8b26b9916434d43613b7943dae42820171d3332909a4d7decf5afd949e1344c05eea0", "2kseBdpArY-Yzcq_Z074", "eeuFJ2gnjhujFYhkhNTh", 3, "2009-05-12 22:12:12", "2009-05-07 20:26:09", "2009-05-1102:20:20", "127.0.0.1", "127.0.0.1", "2009-05-07 19:16:36", "2009-05-12 22:12:12", null, null], [2,"blah", "administrator", "d5fd2420f52b75ac9872894024a3f94789c66238b24703b3440c48f72f9b259ec69038e697257719775a3864daa65745bf93b39738c8a721f6ffe3d8661d102b", "asB7XjpiULN2qcbb09Pe", "9f9cba74dbb14a5158680943bca7d6ffcb51d1a8e06f7320f61b6ff4ee1787c794f277ed16a610184af310c9cafab068906faa6b796be700059ee82f531794ce", "i24HSmou7xWZcMmOSrW4", "mYQ8DNUwgKUYLTUyuhS4", 1, "2009-05-12 22:18:25", null, "2009-05-12 22:12:54", null, "127.0.0.1", "2009-05-12 22:12:54", "2009-05-12 22:18:25", null, null], [3, "blahh", "administrator", "3651da3204bc8863115d7731046eaf1e3daccb68de1c88f6bb423603fc70e15580f7c5e8e1c0707e3ac4a5681cc0112cbf38514411daacb62d32436a18673baa", "j-HxMWnrLHqUjaVfBYuP", "41fbe8c1d90475a8fbd9069d7f357fd477879320b330b5d6e02c71512668a5f9ef6d275b688c9aa3b89e25c268f20b9600a8cc6a3c5f5cf7e12f78e311b03838", "fiK9uWM7M6DgKIULjosH", "WnwqeRsAl6W5bTmK9tYq", 0, null, null, null, null, null, "2009-05-12 22:13:07", "2009-05-12 22:13:07", null, null], [4, "ufff", "administrator", "98fb076060712e1b47a0e284ff22624bed0274c93c437c2fa9f726ec27ea4fdae5037233bce478b069782e77371da6320048a8a857acc70d57fd8ccef2fac773", "hqBuUXbbu3REunXSx51T", "3abddb61d0fe2a1e6d609fd0ef3c23df3e8187a07054687f8d2da2b8843aae14964bb3af91dac2661a5db4c40c9983cb24ad14d7ec17f009cffc24f8b114c7bb", "ndrIDKn7R-F1P7R5C-Oi", "hUPIhTSG_1-bH8EMy0cD", 1, "2009-05-12 22:19:41", null, "2009-05-12 22:18:38", null, "127.0.0.1", "2009-05-12 22:18:38", "2009-05-12 22:19:41", null, null], [5, "wow", "administrator", "3c6b497e860cdcd34765f18fbae725b3162219d73d90f67d9b38d72d27971d9d89e486a0a45448699fbfd37128b00735b7b3886183beebbf50184c105ea9ccf5", "wtkyXmPbTC5lwLzct2MF", "9146603b10f88af9ded8f4b4e1a87db3a7b1f2963bee8c827b5e6d703a8abfd91301668b57a20bac844d6b2643ef6525e210924651b525168fdeb12ce912f65f", "Q4GGNnJNoBUDOxIPjLYh", "iYLzXhu9mDeRnYeuXEBs", 1, "2009-05-12 22:20:15", null, "2009-05-12 22:19:51", null, "127.0.0.1", "2009-05-12 22:19:51", "2009-05-12 22:20:15", null, null]]);
                }
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
                  },
                  success : function(response){
                    // we need to reconfigure ArrayReader's recordType in order to correctly interprete
                    // the new order of data fields coming from the server

                    // we receive new record order from the server, which is less error-prone than trying to
                    // blindly track the column order on the client side
                    columns = Ext.decode(response.responseText).columns;
                    columnsInNewOrder = [];
                    Ext.each(columns, function(c){
                      columnsInNewOrder.push({name:c});
                    });
                    newRecordType = Ext.data.Record.create(columnsInNewOrder);
                    this.store.reader.recordType = newRecordType; // yes, recordType is a protected property, but that's the only way we can do it, and it seems to work
                  },
                  scope : this
                });
              }
            JS
      
          }
        end
      end
    end
  end
end