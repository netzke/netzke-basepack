{
  trackMouseOver: true,
  loadMask: true,
  autoScroll: true,

  componentLoadMask: {msg: "Loading..."},
  deleteMaskMsg: "Deleting...",

  initComponent: function(){
    this.plugins = []; // checkbox colums is a special case, being a plugin

    var filters = [];
    var metaColumn;

    // Run through columns and set up different configuration for each
    Ext.each(this.columns, function(c, i){
      // We will not use meta columns as actual columns (not even hidden) - only to create the records
      if (c.meta) {
        metaColumn = c;
        return;
      }

      // Apply default column config
      Ext.applyIf(c, this.defaultColumnConfig);

      // setting dataIndex separately
      c.dataIndex = c.name;

      // Automatically calculated default values
      if (!c.header) {c.header = c.label || c.name.humanize()}

      // Set initial association values
      if (this.inlineData) {
        this.associationValues = this.inlineData.setAssociationValues;
      }

      // normalize editor
      this.normalizeEditor(c);

      // if comboboxOptions are provided, we render a combobox instead of textfield
      if (c.comboboxOptions && c.editor.xtype === "textfield") {
        c.editor = {xtype: "combobox", options: c.comboboxOptions.split('\\n')}
      }

      // collect filters
      if (c.filterable){
        filters.push({type: this.filterTypeForAttrType(c.attrType), dataIndex: c.name});
      }

      if (c.editor && c.editor.xtype == 'checkbox') {
        // Special case of checkbox column
        var plugin = new Ext.ux.grid.CheckColumn(c);
        this.plugins.push(plugin);
        this.columns[i] = plugin;
      } else {
        // a "normal" column, not a plugin
        if (!c.readOnly && !this.prohibitUpdate) {
          // c.editor contains complete config of the editor
          c.editor = Ext.apply({
            parentId: this.id,
            name: c.name,
            selectOnFocus: true
          }, c.editor);
        } else {
          c.editor = null;
        }

        this.normalizeRenderer(c);

        this.setDefaultColumnType(c);

        // Set rendeder for association columns (the one displaying associations by the specified method instead of id)
        if (c.assoc) {
          c.scope = this;
          var passedRenderer = c.renderer; // renderer we got from normalizeRenderer
          c.renderer = function(value, a, r, ri, ci){
            var editor = this.getColumnModel().getColumnAt(ci).getEditor();
            var recordFromStore = editor && editor.getStore && editor.getStore().getById(value);
            var renderedValue;
            if (recordFromStore) {
              renderedValue = recordFromStore.get('field2');
            } else if (c.assoc && r.get('_meta')) {
              renderedValue = r.get('_meta').associationValues[c.name] || value;
            } else {
              renderedValue = value;
            }

            return passedRenderer ? passedRenderer.call(this, renderedValue) : renderedValue;
          };
        }

      }

    }, this);

    /* ... and done with columns */

    // Filters
    this.gridFilters = new Ext.ux.grid.GridFilters({filters:filters});
    if (this.enableColumnFilters) {
     this.plugins.push(this.gridFilters);
    }

    // Create Ext.data.Record constructor specific for our particular column configuration
    this.recordConfig = [];
    Ext.each(this.columns, function(column){
      var extraConfig = {};
      if (column.attrType == 'datetime') {
        extraConfig.type = 'date';
        extraConfig.dateFormat = 'Y-m-d g:i:s';
      };
      this.recordConfig.push(Ext.apply({name: column.name, defaultValue: column.defaultValue}, extraConfig));
    }, this);
    this.Row = Ext.data.Record.create(this.recordConfig);

    // After we created the record (model), we can get rid of the meta column
    this.columns.remove(metaColumn);

    // Drag'n'Drop
    if (this.enableRowsReordering){
      this.ddPlugin = new Ext.ux.dd.GridDragDropRowOrder({
          scrollable: true // enable scrolling support (default is false)
      });
      this.plugins.push(this.ddPlugin);
    }




    // HttpProxy that uses our custom connection
    var directProxy = new Ext.data.DirectProxy({directFn: Netzke.providers[this.id].getData});

    directProxy.on('load', function (that, t, options) {
      // besides getting data into the store, we may also get commands to execute
      var response = t.result;

      // delete data-related properties
      Ext.each(['data', 'total', 'success'], function(property){delete response[property];});
      this.bulkExecute(response);
    }, this);

    // Data store
    this.store = new Ext.data.Store({
        pruneModifiedRecords: true,
        proxy: this.proxy = directProxy,
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
      emptyMsg: 'Empty',
      displayInfo: true,
      plugins: this.gridFilters ? [this.gridFilters] : []
    }) : this.bbar;

    // Selection model
    if (!this.sm) this.sm = new Ext.grid.RowSelectionModel();

    // Now let Ext.grid.EditorGridPanel do the rest (original initComponent)
    Netzke.classes.Basepack.GridPanel.superclass.initComponent.call(this);

    // Persistence-related events
    if (this.persistentConfig) {
      // Hidden change event
      this.getColumnModel().on('hiddenchange', this.onColumnHiddenChange, this);

      // Inform the server part about column operations
      this.on('columnresize', this.onColumnResize, this);
      this.on('columnmove', this.onColumnMove, this);
    }

    // Context menu
    if (this.contextMenu) {
      this.on('rowcontextmenu', this.onRowContextMenu, this);
    }

    // Disabling/enabling editInForm button according to current selection
    if (this.enableEditInForm) {
      this.getSelectionModel().on('selectionchange', function(selModel){
        var disabled;
        if (!selModel.hasSelection()) {
          disabled = true;
        } else {
          // Disable "edit in form" button if new record is present in selection
          disabled = !selModel.each(function(r){
            if (r.isNew) { return false; }
          });
        };
        this.actions.editInForm.setDisabled(disabled);
      }, this);
    }

    // Load data AFTER the toolbar is bound to the store, which will provide for correct page number
    if (this.loadInlineData) {
      this.getStore().loadData(this.inlineData);

      // If rows per page specified, fake store.lastOptions as if the data was loaded
      // by PagingToolbar (for correct functionning of refresh tool and extended search)
      if (this.rowsPerPage) {
        this.getStore().lastOptions = {params:{limit:this.rowsPerPage, start:0}}; // this is how PagingToolbar does it...
      }

      // inlineData may also contain commands (TODO: make it DRY, as this code repeats in multiple places...)
      // delete data-related properties
      Ext.each(['data', 'total', 'success'], function(property){ delete this.inlineData[property]; }, this);
      this.bulkExecute(this.inlineData);
    }

    // Process selectionchange event
    this.getSelectionModel().on('selectionchange', function(selModel){
      // enable/disable actions
      if (this.actions.del) this.actions.del.setDisabled(!selModel.hasSelection() || this.prohibitDelete);
      if (this.actions.edit) this.actions.edit.setDisabled(selModel.getCount() != 1 || this.prohibitUpdate);
    }, this);

    // Drag n Drop event
    if (this.enableRowsReordering){
      this.ddPlugin.on('afterrowmove', this.onAfterRowMove, this);
    }

    // GridView
    this.getView().getRowClass = this.defaultGetRowClass;

    // When starting editing as assocition column, pre-load the combobox store from the meta column, so that we don't see the real value of this cell (the id of the associated record), but rather the associated record by the configured method.
    this.on('beforeedit', function(e){
      var column = this.getColumnModel().getColumnById(this.getColumnModel().getColumnId(e.column));
      if (column.assoc && column.getEditor().isXType('combo') && e.record.get('_meta')) {
        column.getEditor().getStore().loadData({
          data: [[e.record.get(e.field), e.record.get('_meta').associationValues[e.field]]]
        });
      }
    }, this);
  },

  filterTypeForAttrType: function(attrType){
    var map = {
      integer :'Numeric',
      decimal :'Numeric',
      datetime:'Date',
      date    :'Date',
      string  :'String',
      'boolean': 'Boolean'
    };
    return map[attrType] || 'String';
  },

  attrTypeEditorMap: {
    integer  : "numberfield",
    "float"  : "numberfield",
    "boolean": "checkbox",
    decimal  : "numberfield",
    datetime : "datetimefield",
    date     : "datefield",
    string   : "textfield"
  },

  setAssociationValues: function(assocObj) {
    this.associationValues = assocObj;
  },

  onAdd: function(){
      var r = new this.Row();
      r.isNew = true; // to distinguish new records
      // r.set('id', r.id); // otherwise later r.get('id') returns empty string
      this.stopEditing();
      this.getStore().add(r);

      // Set default values
      this.getStore().fields.each(function(field){
        r.set(field.name, field.defaultValue);
      });

      this.tryStartEditing(this.store.indexOf(r));
    },

  onDel: function() {
      Ext.Msg.confirm(this.i18n.confirm, this.i18n.areYouSure, function(btn){
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
            if (!this.deleteMask) this.deleteMask = new Ext.LoadMask(this.bwrap, {msg: this.deleteMaskMsg});
            this.deleteMask.show();
            // call API
            this.deleteData({records: Ext.encode(records)}, function(){
              this.deleteMask.hide();
            }, this);
          }
        }
      }, this);
    },

  onApply: function(){
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

    },

  // Handlers for tools
  //

  onRefresh: function() {
      if (this.fireEvent('refresh', this) !== false) {
        this.store.reload();
      }
    },

  // Event handlers
  //

  onColumnResize: function(index, size){
      this.resizeColumn({
        index:index,
        size:size
      });
    },

  onColumnHiddenChange: function(cm, index, hidden){
      this.hideColumn({
        index:index,
        hidden:hidden
      });
    },

  onColumnMove: function(oldIndex, newIndex){
      this.moveColumn({
        old_index:oldIndex,
        new_index:newIndex
      });

      var newRecordConfig = [];
      Ext.each(this.getColumnModel().config, function(c){newRecordConfig.push({name: c.name})});
      delete this.Row; // old record constructor
      this.Row = Ext.data.Record.create(newRecordConfig);
      this.getStore().reader.recordType = this.Row;
    },

  onRowContextMenu: function(grid, rowIndex, e){
      e.stopEvent();
      var coords = e.getXY();

      if (!grid.getSelectionModel().isSelected(rowIndex)) {
        grid.getSelectionModel().selectRow(rowIndex);
      }

      var menu = new Ext.menu.Menu({
        items: this.contextMenu
      });

      menu.showAt(coords);
    },

  onAfterRowMove: function(dt, oldIndex, newIndex, records){
      var ids = [];
      // collect records ids
      Ext.each(records, function(r){ids.push(r.id)});
      // call GridPanel's API
      this.moveRows({ids:Ext.encode(ids), new_index: newIndex});
    },

  // Other methods
  //

  loadExceptionHandler: function(proxy, options, response, error){
    if (response.status == 200 && (responseObject = Ext.decode(response.responseText)) && responseObject.flash){
      this.feedback(responseObject.flash);
    } else {
      if (error){
        this.feedback(error.message);
      } else {
        this.feedback(response.statusText);
      }
    }
  },

  update: function(){
      this.store.reload();
    },

  loadStoreData: function(data){
      this.store.loadData(data);
      Ext.each(['data', 'total', 'success'], function(property){delete data[property];}, this);
      this.bulkExecute(data);
    },

  // try editing the first editable (i.e. not hidden, not read-only) sell
  tryStartEditing: function(row){
      var editableIndex = 0;
      Ext.each(this.getColumnModel().config, function(c){
        // skip columns that cannot be edited
        if (!(c.hidden == true || c.editable == false || !c.editor || c.attrType == 'boolean')) {
          return false;
        }
        editableIndex++;
      });

      if (editableIndex < this.getColumnModel().config.length) {this.startEditing(row, editableIndex);}
    },

  // Called by the server side to update newly created records
  updateNewRecords: function(records){
      this.updateRecords(records);
    },

  // Called by the server side to update modified records
  updateModRecords: function(records){
      this.updateRecords(records, true);
    },

  // Updates modified or newly created records, by record ID
  // Example of the records argument (updated columns):
  //   {1098 => [1, 'value1', 'value2'], 1099 => [2, 'value1', 'value2']}
  // Example of the records argument (new columns, id autogenerated by Ext):
  //   {"ext-record-200" => [1, 'value1', 'value2']}
  updateRecords: function(records, mod){
      if (!mod) {mod = false;}
      var modRecordsInGrid = [].concat(this.store.getModifiedRecords()); // there must be a better way to clone an array...
      // replace arrays of data in the args object with Ext.data.Record objects
      for (var k in records){
        records[k] = this.store.reader.readRecords({data:[records[k]]}).records[0];
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
      this.getSelectionModel().fireEvent('selectionchange', this.getSelectionModel());
    },

  defaultGetRowClass: function(r){
    return r.isNew ? "grid-dirty-record" : ""
  },

  selectFirstRow: function(){
    this.getSelectionModel().suspendEvents();
    this.getSelectionModel().selectRow(0);
    this.getSelectionModel().resumeEvents();
  },

  setDefaultColumnType: function(c) {
    if (c.xtype || c.renderer) return;

    switch (c.attrType) {
      case 'datetime': {
        c.xtype = 'datecolumn';
        c.format = c.format || "Y-m-d g:i:s";
        break;
      }
    }
  },

  // Normalizes the renderer for a column.
  // Renderer may be:
  // 1) a string that contains the name of the function to be used as renderer.
  // 2) an array, where the first element is the function name, and the rest - the arguments
  // that will be passed to that function along with the value to be rendered.
  // The function is searched in the following objects: 1) Ext.util.Format, 2) this.
  // If not found, it is simply evaluated. Handy, when as renderer we receive an inline JS function,
  // or reference to a function in some other scope.
  // So, these will work:
  // * "uppercase"
  // * ["ellipsis", 10]
  // * ["substr", 3, 5]
  // * "myRenderer" (if this.myRenderer is a function)
  // * ["Some.scope.Format.customRenderer", 10, 20, 30] (if Some.scope.Format.customRenderer is a function)
  // * "function(v){ return 'Value: ' + v; }"
  normalizeRenderer: function(c) {
    if (!c.renderer) return;

    var name, args = [];

    if ('string' === typeof c.renderer) {
      name = c.renderer;
    } else {
      name = c.renderer[0];
      args = c.renderer.slice(1);
    }

    // First check whether Ext.util.Format has it
    if (Ext.isFunction(Ext.util.Format[name])) {
       c.renderer = Ext.util.Format[name].createDelegate(this, args, 1);
    } else if (Ext.isFunction(this[name])) {
      // ... then if our own class has it
      c.renderer = this[name].createDelegate(this, args, 1);
    } else {
      // ... and, as last resort, evaluate it (allows passing inline javascript function as renderer)
      eval("c.renderer = " + c.renderer + ";");
    }
  },

  normalizeEditor: function(c) {
    if (c.assoc) {
    } else {
      if (c.editor) {
        c.editor = Ext.isObject(c.editor) ? c.editor : {xtype:c.editor};
      } else {
        c.editor = {xtype: this.attrTypeEditorMap[c.attrType] || 'textfield'}
      }
    }

  },

  onEdit: function(){
    var row = this.getSelectionModel().getSelected();
    if (row){
      this.tryStartEditing(this.store.indexOf(row));
    }
  }

  // :reorder_columns => <<-END_OF_JAVASCRIPT.l,
  //   function(columns){
  //     columnsInNewShipment = [];
  //     Ext.each(columns, function(c){
  //       columnsInNewShipment.push({name:c});
  //     });
  //     newRecordType = Ext.data.Record.create(columnsInNewShipment);
  //     this.store.reader.recordType = newRecordType; // yes, recordType is a protected property, but that's the only way we can do it, and it seems to work for now
  //   }
  // END_OF_JAVASCRIPT

}
