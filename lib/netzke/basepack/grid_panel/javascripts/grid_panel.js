{
  trackMouseOver: true,
  loadMask: true,
  autoScroll: true,

  componentLoadMask: {msg: "Loading..."},
  deleteMaskMsg: "Deleting...",
  multiSelect: true,

  initComponent: function(){
    this.plugins = this.plugins || [];
    this.features = this.features || [];

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

      // WIP: disable checkbox temporarily
      if (false && c.editor && c.editor.xtype == 'checkbox') {
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

        // this.setDefaultColumnType(c);

        // Set rendeder for association columns (the one displaying associations by the specified method instead of id)
        if (c.assoc) {
          c.scope = this;
          var passedRenderer = c.renderer; // renderer we got from normalizeRenderer
          c.renderer = function(value, a, r, ri, ci){
            // HACK: any better way to access columns in Ext 4 grid?
            var editor = this.columns[ci].getEditor(),
              // HACK: using private property 'store'
              recordFromStore = editor && editor.isXType('combobox') && editor.store.findRecord('field1', value),
              renderedValue;

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
    // TODO: fix the icons for column filters (like "greater than")
    this.features = [{
      encode: true,
      ftype: 'filters',
      filters: filters
    }];


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
    // this.Row = Ext.data.Record.create(this.recordConfig);

    // Define the model
    Ext.define(this.id, {
        extend: 'Ext.data.Model',
        fields: this.recordConfig
    });

    // After we created the record (model), we can get rid of the meta column
    Ext.Array.remove(this.columns, metaColumn);

    // Prepare column model config with columns in the correct order; columns out of order go to the end.
    var colModelConfig = [];
    var columns = this.columns;

    Ext.each(this.columnsOrder, function(c) {
      var mainColConfig;
      Ext.each(this.columns, function(oc) {
        if (c.name === oc.name) {
          mainColConfig = Ext.apply({}, oc);
          // oc.inOrder = true;
          return false;
        }
      });

      colModelConfig.push(Ext.apply(mainColConfig, c));
    }, this);

    // We don't need original columns any longer
    delete this.columns;

    // ... instead - define a custom column model
    this.colModel = new Ext.grid.ColumnModel(colModelConfig);

    // Drag'n'Drop
    if (this.enableRowsReordering){
      this.ddPlugin = new Ext.ux.dd.GridDragDropRowOrder({
        scrollable: true // enable scrolling support (default is false)
      });
      this.plugins.push(this.ddPlugin);
    }

    // Cell editing
    var cellEditing = Ext.create('Ext.grid.plugin.CellEditing', {pluginId: 'celleditor'});

    this.plugins.push(cellEditing);

    // DirectProxy that uses our Ext.direct provider
    // this.proxy = new Ext.data.DirectProxy({directFn: Netzke.providers[this.id].getData});
    var proxy = {
      type: 'direct',
      directFn: Netzke.providers[this.id].getData,
      reader: {
        type: 'array',
        root: 'data'
      }
    }

    // WIP
    // this.proxy.on('load', function (self, t, options) {
    //   // besides getting data into the store, we may also get commands to execute
    //   var response = t.result;
    //
    //   // delete data-related properties
    //   Ext.each(['data', 'total', 'success'], function(property){delete response[property];});
    //   this.bulkExecute(response);
    // }, this);

    // Data store
    // this.store = this.buildStore();

    this.store = Ext.create('store.store', {
      lastOptions: {params:{limit:this.rowsPerPage, start:0}},
      xtype: 'store',
      model: this.id,
      proxy: proxy,
      pruneModifiedRecords: true,
      remoteSort: true,
      pageSize: this.rowsPerPage,
      listeners:{'loadexception':{
        fn:this.loadExceptionHandler,
        scope:this
      }}
    });


    // Paging toolbar
    this.dockedItems = this.dockedItems || [];

    this.dockedItems.push({
      xtype: 'pagingtoolbar',
      dock: 'bottom',
      store: this.store,
      items: ["-"].concat(this.bbar) // append the old bbar. TODO: get rid of it.
    });

    delete this.bbar;

    // WIP: we may need some of this later
    // this.dockedItems.push(this.enablePagination) ? new Ext.PagingToolbar(Ext.copyTo({
    //   pageSize : this.rowsPerPage,
    //   items : this.bbar ? ["-"].concat(this.bbar) : [],
    //   store : this.store,
    //   emptyMsg: this.i18n.empty,
    //   displayInfo: true,
    //   plugins: this.gridFilters ? [this.gridFilters] : []
    // }, this.i18n, 'emptyMsg,firstText,prevText,nextText,lastText,beforePageText,afterPageText,refreshText,displayMsg')) : this.bbar;

    // Now let Ext.grid.EditorGridPanel do the rest (original initComponent)
    this.callParent();

    // Persistence-related events
    if (this.persistence) {
      // Hidden change event
      // WIP
      // this.getColumnModel().on('hiddenchange', this.onColumnHiddenChange, this);

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
      this.getSelectionModel().on('selectionchange', function(selModel, selected){
        var disabled;
        if (selected.length === 0) { // empty?
          disabled = true;
        } else {
          // Disable "edit in form" button if new record is present in selection
          Ext.each(selected, function(r){
            if (r.isNew) { disabled = true; return false; }
          });
        };
        this.actions.editInForm.setDisabled(disabled);
      }, this);
    }

    // Load data AFTER the toolbar is bound to the store, which will provide for correct page number
    if (this.loadInlineData) {
      this.getStore().loadData(this.inlineData.data);

      // If rows per page specified, fake store.lastOptions as if the data was loaded
      // by PagingToolbar (for correct functionning of refresh tool and extended search)
      // WIP: this is no longer working, but we need to FIXME it
      // if (this.rowsPerPage) {
      //   this.getStore().lastOptions = {params:{limit:this.rowsPerPage, start:0}}; // this is how PagingToolbar does it...
      // }

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
    // WIP
    // this.on('beforeedit', function(e){
    //   var column = this.getColumnModel().getColumnById(this.getColumnModel().getColumnId(e.column));
    //   if (column.assoc && column.getEditor().isXType('combo') && e.record.get('_meta')) {
    //     column.getEditor().getStore().loadData({
    //       data: [[e.record.get(e.field), e.record.get('_meta').associationValues[e.field]]]
    //     });
    //   }
    // }, this);
  },

  buildStore: function() {
    return new Ext.data.Store({
      pruneModifiedRecords: true,
      proxy: this.proxy,
      // reader: new Ext.data.ArrayReader({root: "data", totalProperty: "total", successProperty: "success", id:0}, this.Row),
      remoteSort: true,
      pageSize: this.rowsPerPage,
      listeners:{'loadexception':{
        fn:this.loadExceptionHandler,
        scope:this
      }}
    });
  },

  filterTypeForAttrType: function(attrType){
    var map = {
      integer :'numeric',
      decimal :'numeric',
      datetime:'date',
      date    :'date',
      string  :'string',
      'boolean': 'boolean'
    };
    return map[attrType] || 'string';
  },

  attrTypeEditorMap: {
    integer  : "numberfield",
    "float"  : "numberfield",
    "boolean": "checkbox",
    decimal  : "numberfield",
    // datetime : "datetimefield", WIP: waiting for Ext 4 fix
    datetime : "datefield",
    date     : "datefield",
    string   : "textfield"
  },

  setAssociationValues: function(assocObj) {
    this.associationValues = assocObj;
  },

  // Handler for the 'add' button
  onAddInline: function(){
    // var r = new this.Row();
    var r = Ext.ModelManager.create({}, this.id),
        editor = this.getPlugin('celleditor');

    r.isNew = true; // to distinguish new records
    // r.set('id', r.id); // otherwise later r.get('id') returns empty string
    // this.getPlugin('celleditor').stopEdit();

    this.getStore().add(r);

    // WIP: Set default values
    // this.getStore().fields.each(function(field){
    //   r.set(field.name, field.defaultValue);
    // });

    this.tryStartEditing(r);
  },

  onDel: function() {
      Ext.Msg.confirm(this.i18n.confirmation, this.i18n.areYouSure, function(btn){
        if (btn == 'yes') {
          var records = [];
          var selection = this.getView().getSelectedNodes();
          this.getSelectionModel().selected.each(function(r){
            if (r.isNew) {
              // this record is not know to server - simply remove from store
              this.store.remove(r);
            } else {
              records.push(r.getId());
            }
          }, this);

          if (records.length > 0){
            if (!this.deleteMask) this.deleteMask = new Ext.LoadMask(this.getEl(), {msg: this.deleteMaskMsg});
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
      var newRecords = [],
          updatedRecords = [],
          store = this.getStore();

      Ext.each(store.getUpdatedRecords().concat(store.getNewRecords()),
        function(r) {
          if (r.isNew) {
            newRecords.push(Ext.apply(r.getChanges(), {id:r.getId()}));
          } else {
            updatedRecords.push(Ext.apply(r.getChanges(), {id:r.getId()}));
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

        if (this.getStore().getProxy().extraParams !== {}) {
          params.base_params = Ext.encode(this.getStore().getProxy().extraParams);
        }

        this.postData(params);
      }

    },

  // Handlers for tools
  //

  onRefresh: function() {
      if (this.fireEvent('refresh', this) !== false) {
        this.store.load();
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
      this.store.load();
    },

  loadStoreData: function(data){
    var dataRecords = this.getStore().getProxy().getReader().read(data);
    this.getStore().loadData(dataRecords.records);
    Ext.each(['data', 'total', 'success'], function(property){delete data[property];}, this);
    this.bulkExecute(data);
  },

  // Tries editing the first editable (i.e. not hidden, not read-only) sell
  tryStartEditing: function(r){
    var editableIndex = 0;
    Ext.each(this.initialConfig.columns, function(c){
      // skip columns that cannot be edited
      if (!(c.hidden == true || c.editable == false || !c.editor || c.attrType == 'boolean')) {
        return false;
      }
      editableIndex++;
    });

    if (editableIndex < this.initialConfig.columns.length) {this.getPlugin('celleditor').startEdit(r, this.columns[editableIndex]);}
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
      var modRecordsInGrid = [].concat(this.store.getUpdatedRecords()); // there must be a better way to clone an array...
      // replace arrays of data in the args object with Ext.data.Record objects
      for (var k in records){
        records[k] = this.getStore().getProxy().getReader().read({data:[records[k]]}).records[0];
      }
      // for each new record write the data returned by the server, and commit the record
      Ext.each(modRecordsInGrid, function(recordInGrid){
        if (mod ^ recordInGrid.isNew) {
          // if record is new, we access its id by "id", otherwise, the id is in the primary key column
          var recordId = recordInGrid.getId();
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
      var modRecords = this.store.getUpdatedRecords();
      if (modRecords.length == 0) {
        // if all records are accepted, reload the grid (so that eventual order/filtering is correct)
        this.store.load();

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
      name = c.renderer.camelize(true);
    } else {
      name = c.renderer[0];
      args = c.renderer.slice(1);
    }

    // First check whether Ext.util.Format has it
    if (Ext.isFunction(Ext.util.Format[name])) {
       c.renderer = Ext.Function.bind(Ext.util.Format[name], this, args, 1);
    } else if (Ext.isFunction(this[name])) {
      // ... then if our own class has it
      c.renderer = Ext.Function.bind(this[name], this, args, 1);
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

  // Inline editing of 1 row
  onEdit: function(){
    var row = this.getSelectionModel().selected.first();
    if (row){
      this.tryStartEditing(row);
    }
  },

  // Not a very clean approach to clean-up. The problem is that this way the advanced search functionality stops being really pluggable. With Ext JS 4 find the way to make it truely so.
  onDestroy: function(){
    Netzke.classes.Basepack.GridPanel.superclass.onDestroy.call(this);

    // Destroy the search window (here's the problem: we are not supposed to know it exists)
    if (this.searchWindow) {
      this.searchWindow.destroy();
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
