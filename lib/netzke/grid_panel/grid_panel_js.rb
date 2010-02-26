module Netzke
  class GridPanel < Base
    module GridPanelJs
      def self.included(base)
        base.extend ClassMethods
      end

      def js_config
        res = super
        res.merge!(:clmns => columns)
        res.merge!(:model => config[:model])
        res.merge!(:inline_data => get_data) if ext_config[:load_inline_data]
        res.merge!(:pri => data_class.primary_key)
        res
      end

      module ClassMethods

        def js_base_class 
          'Ext.grid.EditorGridPanel'
        end

        # Ext.Component#initComponent, built up from pices (dependent on class configuration)
        def js_init_component
        
          # Optional "edit in form"-related events
          edit_in_form_events = <<-END_OF_JAVASCRIPT if config[:edit_in_form_available]
            if (this.enableEditInForm) {
              this.getSelectionModel().on('selectionchange', function(selModel){
                // Disable "edit in form" button if new record is present in selection
                var disabled = !selModel.each(function(r){
                  if (r.isNew) { return false; }
                });
                this.actions.editInForm.setDisabled(disabled);
              }, this);
            }
          END_OF_JAVASCRIPT
        
          # Result
          <<-END_OF_JAVASCRIPT
            function(){
              if (!this.clmns) {this.feedback('No columns defined for grid '+this.id);}

              /* Process columns - all in sake of creating the column model */
              // Normalize columns passed in the config
              var normClmns = [];
              Ext.each(this.clmns, function(c){
                if (!c.excluded) {
                  // normalize columns
                  if (typeof c == 'string') {
                    normClmns.push({name:c});
                  } else {
                    normClmns.push(c);
                  }
                }
              });

              delete this.clmns; // we don't need them anymore
            
              var cmConfig = []; // column model config - we'll use it later to create the ColumnModel
              this.plugins = []; // checkbox colums is a special case, being a plugin

              var filters = [];
            
              // Run through columns
              Ext.each(normClmns, function(c){
                // Apply default column config
                Ext.applyIf(c, this.defaultColumnConfig);

                // setting dataIndex separately
                c.dataIndex = c.name;

                // Automatically calculated default values
                if (!c.header) {c.header = c.name.humanize()}

                // normalize editor
                if (c.editor) {
                  c.editor = Netzke.isObject(c.editor) ? c.editor : {xtype:c.editor};
                } else {
                  c.editor = {xtype: 'textfield'}
                }
              
                // collect filters
                // Not compatible with Ext 3.0
                //if (c.withFilters){
                //  filters.push({type:Ext.netzke.filterMap[c.editor.xtype], dataIndex:c.name});
                //}

                if (c.editor && c.editor.xtype == 'checkbox') {
                  // Special case of checkbox column
                  var plugin = new Ext.ux.grid.CheckColumn(c);
                  this.plugins.push(plugin);
                  cmConfig.push(plugin);
                } else {
                  // a "normal" column, not a plugin
                  if (!c.readOnly && !this.prohibitUpdate) {
                    // c.editor contains complete config of the editor
                    var xtype = c.editor.xtype;
                    c.editor = Ext.ComponentMgr.create(Ext.apply({
                      parentId: this.id,
                      name: c.name,
                      selectOnFocus:true
                    }, c.editor));
                  } else {
                    c.editor = null;
                  }

                  // set the renderer
                  if (c.renderer && !Ext.isArray(c.renderer) && c.renderer.match(/^\\s*function\\s*\\(/)) {
                    // if the renderer is an inline function - eval it (double escaping because we are inside of the Ruby string here...)
                    eval("c.renderer = " + c.renderer + ";");
                  } else {
                    // othrewise it's a string representing the name of the renderer or an json-encoded array,
                    // where the first parameter is the renderer's name, and the rest - parameters that should be
                    // passed to the renderer at the moment of calling
                    var renderer = Ext.netzke.normalizedRenderer(c.renderer);
                    if (renderer != null) c.renderer = renderer;
                  }
                
                  // add to the list
                  cmConfig.push(c);
                }

              }, this);

              // Finally, create the ColumnModel based on processed columns
              this.cm = new Ext.grid.ColumnModel(cmConfig);
            
              // Hidden change event
              if (this.persistentConfig) {this.cm.on('hiddenchange', this.onColumnHiddenChange, this);}

              /* ... and done with columns */
            
              // Filters
              // Not compatible with Ext 3.0
              // if (this.enableColumnFilters) {
              //  this.plugins.push(new Ext.grid.GridFilters({filters:filters}));
              // }
            
              // Create Ext.data.Record constructor specific for our particular column configuration
              this.recordConfig = [];
              Ext.each(normClmns, function(column){this.recordConfig.push({name:column.name});}, this);
              this.Row = Ext.data.Record.create(this.recordConfig);

              // Drag'n'Drop
              if (this.enableRowsReordering){
                this.ddPlugin = new Ext.ux.dd.GridDragDropRowOrder({
                    scrollable: true // enable scrolling support (default is false)
                });
                this.plugins.push(this.ddPlugin);
              }

              // Explicitely create the connection to get grid's data, 
              // because we don't want the app-wide Ext.Ajax to be used,
              // as we are going to subscribe to its events
              var connection = new Ext.data.Connection({
                url: this.buildApiUrl("get_data"),
                extraParams: {
                  authenticity_token : Netzke.authenticityToken
                },

                // inform Ext.Ajax about our events
                listeners: {
                  beforerequest: function(){
                    Ext.Ajax.fireEvent('beforerequest', arguments);
                  },
                  requestexception: function(){
                    Ext.Ajax.fireEvent('requestexception', arguments);
                  },
                  requestcomplete: function(){
                    Ext.Ajax.fireEvent('requestcomplete', arguments);
                  }
                }
              });

              // besides getting data into the store, we may also get commands to execute
              connection.on('requestcomplete', function(conn, r){
                var response = Ext.decode(r.responseText);

                // delete data-related properties
                Ext.each(['data', 'total', 'success'], function(property){delete response[property];});
                this.bulkExecute(response);
              }, this);

              // HttpProxy that uses our custom connection
              var httpProxy = new Ext.data.HttpProxy(connection);

              // Data store
              this.store = new Ext.data.Store({
                  proxy: this.proxy = httpProxy,
                  reader: new Ext.data.ArrayReader({root: "data", totalProperty: "total", successProperty: "success", id:0}, this.Row),
                  remoteSort: true,
                  listeners:{'loadexception':{
                    fn:this.loadExceptionHandler,
                    scope:this
                  }}
              });

              // Normalize bottom bar
              this.bbar = (this.enablePagination) ? new Ext.PagingToolbar({
                pageSize : this.rowsPerPage,
                items : this.bbar ? ["-"].concat(this.bbar) : [],
                store : this.store, 
                emptyMsg: 'Empty'
              }) : this.bbar;
            
              // Selection model
              this.sm = new Ext.grid.RowSelectionModel();
            
              // Now let Ext.grid.EditorGridPanel do the rest
              // Original initComponent
              #{js_full_class_name}.superclass.initComponent.call(this);
            
              // Inform the server part about column operations
              if (this.persistentConfig) {
                this.on('columnresize', this.onColumnResize, this);
                this.on('columnmove', this.onColumnMove, this);
              }
            
              // Context menu
              if (this.enableContextMenu) {
                this.on('rowcontextmenu', this.onRowContextMenu, this);
              }
            
              // Load data AFTER the toolbar is bound to the store, which will provide for correct page number
              if (this.loadInlineData) {
                this.getStore().loadData(this.inlineData);

                // If rows per page specified, fake store.lastOptions as if the data was loaded
                // by PagingToolbar (for correct functionning of refresh tool and extended search)
                if (this.rowsPerPage) {
                  this.getStore().lastOptions = {params:{limit:this.rowsPerPage, start:0}}; // this is how PagingToolbar does it...
                }
              
                // inlineData may also contain commands (TODO: make it DRY)
                // delete data-related properties
                Ext.each(['data', 'total', 'success'], function(property){delete this.inlineData[property];}, this);
                this.bulkExecute(this.inlineData);
              }
            
              // Process selectionchange event
              this.getSelectionModel().on('selectionchange', function(selModel){
                // enable/disable actions
                this.actions.del.setDisabled(!selModel.hasSelection() || this.prohibitDelete);
                this.actions.edit.setDisabled(selModel.getCount() != 1 || this.prohibitUpdate);
              }, this);
            
              // Drag n Drop event
              if (this.enableRowsReordering){
                this.ddPlugin.on('afterrowmove', this.onAfterRowMove, this);
              }
            
              // GridView
              this.getView().getRowClass = this.defaultGetRowClass;
            
              #{edit_in_form_events}
            }
          
          END_OF_JAVASCRIPT
        
        end

        def js_extend_properties
          res = super
        
          # Generic (non-optional) functionality
          res.merge!(
          {
            :track_mouse_over => true,
            :load_mask        => true,
            :auto_scroll      => true,

            :default_column_config => config_columns.inject({}){ |r, c| c.is_a?(Hash) ? r.merge(c[:name] => c[:default]) : r },
          
            :init_component => js_init_component.l,
          
            # Handlers for actions
            # 
          
            :on_add => <<-END_OF_JAVASCRIPT.l,
              function(){
                var rowConfig = {};
                var r = new this.Row(rowConfig); // TODO: add default values
                r.isNew = true; // to distinguish new records
                // r.set('id', r.id); // otherwise later r.get('id') returns empty string
                this.stopEditing();
                this.getStore().add(r);
                this.tryStartEditing(this.store.indexOf(r));
              }
            END_OF_JAVASCRIPT
  
            :on_edit => <<-END_OF_JAVASCRIPT.l,
              function(){
                var row = this.getSelectionModel().getSelected();
                if (row){
                  this.tryStartEditing(this.store.indexOf(row));
                }
              }
            END_OF_JAVASCRIPT
  
            :on_del => <<-END_OF_JAVASCRIPT.l,
              function() {
                Ext.Msg.confirm('Confirm', 'Are you sure?', function(btn){
                  if (btn == 'yes') {
                    var records = [];
                    this.getSelectionModel().each(function(r){
                      if (r.isNew) {
                        // this record is not know to server - simply remove from store
                        this.store.remove(r);
                      } else {
                        records.push(r.id);
                      }
                    }, this);

                    if (records.length > 0){
                      // call API
                      this.deleteData({records: Ext.encode(records)});
                    }
                  }
                }, this);
              }
            END_OF_JAVASCRIPT
          
            :on_apply => <<-END_OF_JAVASCRIPT.l,
              function(){
                var newRecords = [];
                var updatedRecords = [];
                Ext.each(this.store.getModifiedRecords(),
                  function(r) {
                    if (r.isNew) {
                      newRecords.push(Ext.apply(r.getChanges(), {id:r.id}));
                    } else {
                      updatedRecords.push(Ext.apply(r.getChanges(), {id:r.id}));
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
            END_OF_JAVASCRIPT

            # Handlers for tools
            # 
          
            :on_refresh => <<-END_OF_JAVASCRIPT.l,
              function() {
                if (this.fireEvent('refresh', this) !== false) {
                  this.store.reload();
                }
              }
            END_OF_JAVASCRIPT
    
            # Event handlers
            # 
          
            :on_column_resize => <<-END_OF_JAVASCRIPT.l,
              function(index, size){
                this.resizeColumn({
                  index:index,
                  size:size
                });
              }
            END_OF_JAVASCRIPT
    
            :on_column_hidden_change => <<-END_OF_JAVASCRIPT.l,
              function(cm, index, hidden){
                this.hideColumn({
                  index:index,
                  hidden:hidden
                });
              }
            END_OF_JAVASCRIPT
          
            :on_column_move => <<-END_OF_JAVASCRIPT.l,
              function(oldIndex, newIndex){
                this.moveColumn({
                  old_index:oldIndex,
                  new_index:newIndex
                });

                var newRecordConfig = [];
                Ext.each(this.getColumnModel().config, function(c){newRecordConfig.push({name: c.name})});
                delete this.Row; // old record constructor
                this.Row = Ext.data.Record.create(newRecordConfig);
                this.getStore().reader.recordType = this.Row;
              }
            END_OF_JAVASCRIPT
          
            :on_row_context_menu => <<-END_OF_JAVASCRIPT.l,
              function(grid, rowIndex, e){
                e.stopEvent();
                var coords = e.getXY();
              
                if (!grid.getSelectionModel().isSelected(rowIndex)) {
                  grid.getSelectionModel().selectRow(rowIndex);
                }
              
                var menu = new Ext.menu.Menu({
                  items: this.contextMenu
                });
              
                menu.showAt(coords);
              }
            END_OF_JAVASCRIPT
          
            :on_after_row_move => <<-END_OF_JAVASCRIPT.l,
              function(dt, oldIndex, newIndex, records){
            		var ids = [];
            		// collect records ids
            		Ext.each(records, function(r){ids.push(r.id)});
            		// call GridPanel's API
            		this.moveRows({ids:Ext.encode(ids), new_index: newIndex});
              }
            END_OF_JAVASCRIPT
          
            # Other methods
            # 
          
            :load_exception_handler => <<-END_OF_JAVASCRIPT.l,
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
            END_OF_JAVASCRIPT
  
            :update => <<-END_OF_JAVASCRIPT.l,
              function(){
                this.store.reload();
              }
            END_OF_JAVASCRIPT
  
            :load_store_data => <<-END_OF_JAVASCRIPT.l,
              function(data){
                this.store.loadData(data);
                Ext.each(['data', 'total', 'success'], function(property){delete data[property];}, this);
                this.bulkExecute(data);
              }
            END_OF_JAVASCRIPT
  
            # try editing the first editable (i.e. not hidden, not read-only) sell
            :try_start_editing => <<-END_OF_JAVASCRIPT.l,
              function(row){
                var editableIndex = 0;
                Ext.each(this.getColumnModel().config, function(c){
                  if (!c.hidden && c.editable && c.editor && (c.editor.xtype !== 'checkbox')) {
                    return false;
                  }
                  editableIndex++;
                });
                if (editableIndex < this.getColumnModel().config.length) {this.startEditing(row, editableIndex);}
              }
            END_OF_JAVASCRIPT

            # Called by the server side to update newly created records
            :update_new_records => <<-END_OF_JAVASCRIPT.l,
              function(records){
                this.updateRecords(records);
              }
            END_OF_JAVASCRIPT
          
            # Called by the server side to update modified records
            :update_mod_records => <<-END_OF_JAVASCRIPT.l,
              function(records){
                this.updateRecords(records, true);
              }
            END_OF_JAVASCRIPT
          
            # Updates modified or newly created records, by record ID
            # Example of the records argument (updated columns):
            #   {1098 => [1, 'value1', 'value2'], 1099 => [2, 'value1', 'value2']}
            # Example of the records argument (new columns, id autogenerated by Ext):
            #   {"ext-record-200" => [1, 'value1', 'value2']}
            :update_records => <<-END_OF_JAVASCRIPT.l,
              function(records, mod){
                if (!mod) {mod = false;}
                var modRecordsInGrid = [].concat(this.store.getModifiedRecords()); // there must be a better way to clone an array...

                // replace arrays of data in the args object with Ext.data.Record objects
                for (var k in records){
                  records[k] = this.store.reader.readRecords([records[k]]).records[0];
                }
              
                // for each new record write the data returned by the server, and commit the record
                Ext.each(modRecordsInGrid, function(recordInGrid){
                  if (mod ^ recordInGrid.isNew) {
                    // if record is new, we access its id by "id", otherwise, the id is in the primary key column
                    var recordId = recordInGrid.id;
                    // new data that the server sent us to update this record (identified by the id)
                    var newData =  records[recordId];
                  
                    if (newData){
                      for (var k in newData.data){
                        recordInGrid.set(k, newData.get(k));
                      }

                      recordInGrid.isNew = false;
                      recordInGrid.commit();
                    }
                  
                  }
                }, this);
              
                // clear the selections
                this.getSelectionModel().clearSelections();

                // check if there are still records with errors
                var modRecords = this.store.getModifiedRecords();
                if (modRecords.length == 0) {
                  // if all records are accepted, reload the grid (so that eventual order/filtering is correct)
                  this.store.reload();
                
                  // ... and set default getRowClass function
                  this.getView().getRowClass = this.defaultGetRowClass;
                } else {
                  this.getView().getRowClass = function(r){
                    return r.dirty ? "grid-dirty-record" : ""
                  }
                }
              
                this.getView().refresh();
              }
            END_OF_JAVASCRIPT
          
            :default_get_row_class => <<-END_OF_JAVASCRIPT.l,
              function(r){
                return r.isNew ? "grid-dirty-record" : ""
              }
            END_OF_JAVASCRIPT
          
            :select_first_row => <<-END_OF_JAVASCRIPT.l,
              function(){
                this.getSelectionModel().suspendEvents();
                this.getSelectionModel().selectRow(0);
                this.getSelectionModel().resumeEvents();
              }
            END_OF_JAVASCRIPT
          
            # :reorder_columns => <<-END_OF_JAVASCRIPT.l,
            #   function(columns){
            #     columnsInNewShipment = [];
            #     Ext.each(columns, function(c){
            #       columnsInNewShipment.push({name:c});
            #     });
            #     newRecordType = Ext.data.Record.create(columnsInNewShipment);
            #     this.store.reader.recordType = newRecordType; // yes, recordType is a protected property, but that's the only way we can do it, and it seems to work for now
            #   }
            # END_OF_JAVASCRIPT
          }
          )
        
          # Optional edit in form functionality
          res.merge!(
          {
            :on_successfull_record_creation => <<-END_OF_JAVASCRIPT.l,
              function(){
                this.formWindow.hide();
                this.getStore().reload();
              }
            END_OF_JAVASCRIPT

            :on_successfull_edit => <<-END_OF_JAVASCRIPT.l,
              function(){
                this.editFormWindow.close();
                delete this.editFormWindow;
                this.getStore().reload();
              }
            END_OF_JAVASCRIPT

            :on_edit_in_form => <<-END_OF_JAVASCRIPT.l,
              function(){
                // create the window
                delete this.editFormWindow;
                this.editFormWindow = new Ext.Window({
                  title: 'Edit',
                  layout: 'fit',
                  modal: true,
                  width: 400,
                  height: Ext.lib.Dom.getViewHeight() *0.9,
                  buttons:[{
                    text: 'OK',
                    handler: function(){
                      this.ownerCt.ownerCt.getWidget().onApply();
                    }
                  },{
                    text:'Cancel',
                    handler:function(){
                      this.ownerCt.ownerCt.hide();
                    }
                  }]
                });

                // show it and load the correct aggregatee in it
                this.editFormWindow.show(null, function(){
                  var selModel = this.getSelectionModel();
                  if (selModel.getCount() > 1) {

                    // multiedit
                    this.editFormWindow.setTitle('Multi-edit');
                    this.loadAggregatee({
                      id: "multiEditForm",
                      container: this.editFormWindow.id,
                      callback: function(aggr){
                        // on apply attach ids of selected rows
                        aggr.on('apply', function(){
                          var ids = [];
                          selModel.each(function(r){
                            ids.push(r.id);
                          });
                          aggr.baseParams = {ids: Ext.encode(ids)}
                        }, this);
                      },
                      scope: this
                    });
                  } else {
                  
                    // single edit
                    this.editFormWindow.setTitle('Edit');
                    var recordId = selModel.getSelected().id;
                    this.loadAggregatee({
                      id: "editForm",
                      container: this.editFormWindow.id,
                      params: {
                        record_id: recordId
                      }
                    });
                  }
                }, this);

              }
            END_OF_JAVASCRIPT

            :on_add_in_form => <<-END_OF_JAVASCRIPT.l,
              function(){
                this.loadAggregatee({id: "addForm", callback: function(form){
                  form.on('close', function(){
                    if (form.closeRes === "ok") {
                      this.store.reload();
                    }
                  }, this);
                }, scope: this});
              }
            END_OF_JAVASCRIPT
          }
          ) if config[:edit_in_form_available]
        
          # Optional extended search functionality
          res.merge!(
          {
            :on_search => <<-END_OF_JAVASCRIPT.l,
              function(){
                delete this.searchWindow;
                this.searchWindow = new Ext.Window({
                  title:'Advanced search',
                  layout:'fit',
                  modal: true,
                  width: 400,
                  height: Ext.lib.Dom.getViewHeight() *0.9,
                  closeAction:'hide',
                  buttons:[{
                    text: 'OK',
                    handler: function(){
                      this.ownerCt.ownerCt.closePositively();
                    }
                  },{
                    text:'Cancel',
                    handler:function(){
                      this.ownerCt.ownerCt.closeNegatively();
                    }
                  }],
                  closePositively : function(){
                    this.conditions = this.getWidget().getForm().getValues();
                    this.closeRes = 'OK'; 
                    this.hide();
                  },
                  closeNegatively: function(){
                    this.closeRes = 'cancel'; 
                    this.hide();
                  }
                });

                this.searchWindow.on('hide', function(){
                  if (this.searchWindow.closeRes == 'OK'){
                    var searchConditions = this.searchWindow.conditions;
                    var filtered = false;
                    // check if there's any search condition set
                    for (var k in searchConditions) {
                      if (searchConditions[k].length > 0) {
                        filtered = true;
                        break;
                      }
                    }
                    this.actions.search.setText(filtered ? "Search *" : "Search");
                    this.getStore().baseParams = {extra_conditions: Ext.encode(this.searchWindow.conditions)};
                    this.getStore().load();
                  }
                }, this);

                this.searchWindow.on('add', function(container, searchPanel){
                  searchPanel.on('apply', function(widget){
                    this.searchWindow.closePositively();
                    return false; // stop the event
                  }, this);
                }, this);

                this.searchWindow.show(null, function(){
                  this.searchWindow.closeRes = 'cancel';
                  if (!this.searchWindow.getWidget()){
                    this.loadAggregatee({id:"searchPanel", container:this.searchWindow.id});
                  }
                }, this);

              }
            END_OF_JAVASCRIPT
          
          }
          ) if config[:extended_search_available]
        
          res
        end
      end
    end
  end
end