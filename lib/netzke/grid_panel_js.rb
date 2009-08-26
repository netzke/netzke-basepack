module Netzke
  module GridPanelJs
    def self.included(base)
      base.extend ClassMethods
    end

    def js_config
      res = super
      res.merge!(:clmns => columns)
      res.merge!(:data_class_name => config[:data_class_name])
      res.merge!(:inline_data => get_data) if ext_config[:load_inline_data]
      res
    end

    module ClassMethods

      def js_base_class 
        'Ext.grid.EditorGridPanel'
      end

      # Optional filters
      def js_filters_code
        <<-END_OF_JAVASCRIPT if config[:column_filters_available]
        if (this.enableColumnFilters) {
          var filters = [];
          Ext.each(normClmns, function(c){
            filters.push({type:Ext.netzke.filterMap[c.editor.xtype], dataIndex:c.dataIndex});
          });
          var gridFilters = new Ext.grid.GridFilters({filters:filters});
          this.plugins.push(gridFilters);
        }
        END_OF_JAVASCRIPT
      end

      # Ext.Component#initComponent, built up from pices (dependent on class configuration)
      def js_init_component
        # Edit in form related events
        edit_in_form_events = <<-END_OF_JAVASCRIPT if config[:edit_in_form_available]
          if (this.enableEditInForm) {
            this.getSelectionModel().on('selectionchange', function(selModel){
              this.actions.editInForm.setDisabled(!selModel.hasSelection());
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
                  normClmns.push({dataIndex:c});
                } else {
                  normClmns.push(c);
                }
              }
            });
            delete this.clmns; // we don't need them anymore

            var cmConfig = []; // column model config - we'll use it later to create the ColumnModel
            this.plugins = []; // checkbox colums is a special case, being a plugin

            // Run through each column
            Ext.each(normClmns, function(c){
              Ext.applyIf(c, this.defaultColumnConfig);

              // Automatically calculated default values
              if (!c.header) {c.header = c.dataIndex.humanize()}

              // normalize editor
              if (c.editor) {
                c.editor = Netzke.isObject(c.editor) ? c.editor : {xtype:c.editor};
              } else {
                c.editor = {xtype: 'textfield'}
              }

              if (c.editor && c.editor.xtype == 'checkbox') {
                // Special case of checkbox column
                var plugin = new Ext.grid.CheckColumn(c);
                this.plugins.push(plugin);
                cmConfig.push(plugin);
              } else {
                if (!c.readOnly && !this.prohibitUpdate) {
                  // c.editor either contains xtype of the editor, or complete config of it
                  var editor = Ext.ComponentMgr.create(Ext.apply({
                    parentId:this.id,
                    name: c.dataIndex,
                    // fieldConfig:c,
                    selectOnFocus:true
                  }, c.editor));
                }

                // Set renderer
                var renderer = Ext.netzke.renderer(c.renderer);

                var defaultColumnConfig = {}; // Ext.apply({}, this.defaultColumnConfig);
                var defaultMergedWithPassed = Ext.apply(defaultColumnConfig, c);

                var completeColumnConfig = Ext.apply(defaultMergedWithPassed, {
                  editor    : editor
                });

                cmConfig.push(completeColumnConfig);
              }

            }, this);

            // Finally, create the ColumnModel based on processed columns
            this.cm = new Ext.grid.ColumnModel(cmConfig);
            this.cm.on('hiddenchange', this.onColumnHiddenChange, this);

            /* Done with columns */

            // Create Ext.data.Record constructor specific for our particular column configuration
            this.recordConfig = [];
            Ext.each(normClmns, function(column){this.recordConfig.push({name:column.dataIndex});}, this);
            this.Row = Ext.data.Record.create(this.recordConfig);

            // Explicitely create the connection to get grid's data, 
            // because we don't want the app-wide Ext.Ajax to be used,
            // as we are going to subscribe to its events
            var connection = new Ext.data.Connection({
              url:this.id+"__get_data",
              extraParams : {
                authenticity_token : Ext.authenticityToken
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
            this.bbar = (this.rowsPerPage) ? new Ext.PagingToolbar({
              pageSize : this.rowsPerPage, 
              items : this.bbar ? ["-"].concat(this.bbar) : [],
              store : this.store, 
              emptyMsg: 'Empty'
            }) : this.bbar;
            
            // Selection model
            this.sm = new Ext.grid.RowSelectionModel();
            
            // Filters
            #{js_filters_code}
            
            // Now let Ext.grid.EditorGridPanel do the rest
            // Original initComponent
            Ext.netzke.cache.GridPanel.superclass.initComponent.call(this);
            
            
            // Set the events
            this.on('columnresize', this.onColumnResize, this);
            this.on('columnmove', this.onColumnMove, this);
            
            // this.on('rowclick', function(g,i,e){alert('rowclick');});
            // this.on('click', function(e){console.info(this.getGridEl());}, this);
            
            // Load data after the toolbar is bound to the store, which will provide for correct page number
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
              this.actions.delete.setDisabled(!selModel.hasSelection() || this.prohibitDelete);
              this.actions.edit.setDisabled(selModel.getCount() != 1 || this.prohibitUpdate);
            }, this);
            
            #{edit_in_form_events}
          }
          
        END_OF_JAVASCRIPT
        
      end

      def js_extend_properties
        res = super
        
        # Defaults
        res.merge!(
        {
          :track_mouse_over => true,
          :load_mask        => true,
          :auto_scroll      => true,

          :default_column_config => config_columns.inject({}){ |r, c| r.merge!(c[:data_index] => c[:default]) },
          
          :init_component => js_init_component.l,

          # :on_widget_load => <<-END_OF_JAVASCRIPT.l,
          #   function(){
          #     
          #     // auto-load
          #     if (this.initialConfig.autoLoadData) {
          #       // if we have a paging toolbar, load the first page
          #       if (this.getBottomToolbar() && this.getBottomToolbar().changePage) {this.getBottomToolbar().changePage(0);} else {this.store.load();}
          #     }
          #     
          #   }
          # END_OF_JAVASCRIPT
    
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
              this.refresh();
            }
          END_OF_JAVASCRIPT
  
          :load_store_data => <<-END_OF_JAVASCRIPT.l,
            function(data){
              this.store.loadData(data);
              Ext.each(['data', 'total', 'success'], function(property){delete data[property];}, this);
              this.bulkExecute(data);
            }
          END_OF_JAVASCRIPT
  
          :add => <<-END_OF_JAVASCRIPT.l,
            function(){
              var rowConfig = {};
              // Ext.each(this.initialConfig.columns, function(c){
              //   rowConfig[c.name] = c.defaultValue || ''; // FIXME: if the user is happy with all the defaults, the record won't be 'dirty'
              // }, this);
        
              var r = new this.Row(rowConfig); // TODO: add default values
              r.is_new = true; // to distinguish new records
              r.set('id', r.id); // otherwise later r.get('id') returns empty string
              this.stopEditing();
              this.store.add(r);
              this.tryStartEditing(this.store.indexOf(r));
            }
          END_OF_JAVASCRIPT
  
          :edit => <<-END_OF_JAVASCRIPT.l,
            function(){
              var row = this.getSelectionModel().getSelected();
              if (row){
                this.tryStartEditing(this.store.indexOf(row));
              }
            }
          END_OF_JAVASCRIPT
  
          # try editing the first editable (i.e. not hidden, not read-only) sell
          :try_start_editing => <<-END_OF_JAVASCRIPT.l,
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
          END_OF_JAVASCRIPT

          :delete => <<-END_OF_JAVASCRIPT.l,
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
          
          # Updates modified or newly created records
          # Example of the records argument:
          #   {1098 => [1, 'value1', 'value2'], 1099 => [2, 'value1', 'value2']}
          :update_records => <<-END_OF_JAVASCRIPT.l,
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
                  // there must be a faster way to do this
                  for (var k in r.data){
                    r.set(k, newData.get(k));
                    r.commit();
                    r.is_new = false;
                  }
                }
              });
              
              
            }
          END_OF_JAVASCRIPT
          
          :apply => <<-END_OF_JAVASCRIPT.l,
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
          END_OF_JAVASCRIPT
 
          :select_first_row => <<-END_OF_JAVASCRIPT.l,
            function(){
              this.getSelectionModel().suspendEvents();
              this.getSelectionModel().selectRow(0);
              this.getSelectionModel().resumeEvents();
            }
          END_OF_JAVASCRIPT
          
          :refresh => <<-END_OF_JAVASCRIPT.l,
            function() {
              if (this.fireEvent('refresh', this) !== false) {
                this.store.reload();
              }
            }
          END_OF_JAVASCRIPT
    
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
    
          :on_column_move => <<-END_OF_JAVASCRIPT.l,
            function(oldIndex, newIndex){
              this.moveColumn({
                old_index:oldIndex,
                new_index:newIndex
              });
            }
          END_OF_JAVASCRIPT
        }
        )
        
        # Edit in form
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

          :edit_in_form => <<-END_OF_JAVASCRIPT.l,
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
                    this.ownerCt.getWidget().apply();
                  }
                },{
                  text:'Cancel',
                  handler:function(){
                    this.ownerCt.close();
                  }
                }]
              });

              // show it and load the correct aggregatee in it
              this.editFormWindow.show(null, function(){
                var selModel = this.getSelectionModel();
                if (selModel.getCount() > 1) {
                  this.editFormWindow.setTitle('Multi-edit');
                  // multiedit
                  this.loadAggregatee({
                    id: "multi_edit_form",
                    container: this.editFormWindow.id,
                    callback: function(aggr){
                      aggr.on('apply', function(){
                        var ids = [];
                        selModel.each(function(r){
                          ids.push(r.get('id'));
                        });
                        aggr.baseParams = {ids: Ext.encode(ids)}
                      }, this);
                    },
                    scope: this
                  });
                } else {
                  // single edit
                  this.editFormWindow.setTitle('Edit');
                  var recordId = selModel.getSelected().get('id');
                  this.loadAggregatee({
                    id: "edit_form",
                    container: this.editFormWindow.id,
                    scope: this,
                    record_id: recordId
                  });
                }
              }, this);

            }
          END_OF_JAVASCRIPT

          :add_in_form => <<-END_OF_JAVASCRIPT.l,
            function(){
              if (!this.formWindow) {
                this.formWindow = new Ext.Window({
                  title:'Add',
                  layout: 'fit',
                  modal: true,
                  width: 400,
                  height: Ext.lib.Dom.getViewHeight() *0.9,
                  buttons:[{
                    text: 'OK',
                    handler: function(){
                      this.ownerCt.closePositively();
                    }
                  },{
                    text:'Cancel',
                    handler:function(){
                      this.ownerCt.closeNegatively();
                    }
                  }],
                  closePositively : function(){
                    this.getWidget().apply();
                  },
                  closeNegatively: function(){
                    this.hide();
                  }

                });
              }

              this.formWindow.show(null, function(){
                this.formWindow.closeRes = 'cancel';
                if (!this.formWindow.getWidget()){
                  this.loadAggregatee({id:"new_record_form", container:this.formWindow.id});
                }
              }, this);

            }
          END_OF_JAVASCRIPT
          
        }
        ) if config[:edit_in_form_available]
        
        # Extended search
        res.merge!(
        {
          :search => <<-END_OF_JAVASCRIPT.l,
            function(){
              if (!this.searchWindow){
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
                      this.ownerCt.closePositively();
                    }
                  },{
                    text:'Cancel',
                    handler:function(){
                      this.ownerCt.closeNegatively();
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
                    this.getStore().baseParams = {extra_conditions: Ext.encode(this.searchWindow.conditions)};
                    this.getStore().reload();
                  }
                }, this);

                this.searchWindow.on('add', function(container, searchPanel){
                  searchPanel.on('apply', function(widget){
                    this.searchWindow.closePositively();
                    return false; // stop the event
                  }, this);
                }, this);
              }

              this.searchWindow.show(null, function(){
                this.searchWindow.closeRes = 'cancel';
                if (!this.searchWindow.getWidget()){
                  this.loadAggregatee({id:"search_panel", container:this.searchWindow.id});
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