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

    // Enable filters feature
    if (this.enableColumnFilters) {
      this.features.push({
        encode: true,
        ftype: 'filters'
      });
    }

    // Normalize columns. Extract data fields and meta column.
    this.processColumns();

    // Define the model
    Ext.define(this.id, {
      extend: 'Ext.data.Model',
      idProperty: this.pri, // Primary key
      fields: this.fields
    });
    delete this.pri;
    delete this.fields;

    // Prepare column model config with columns in the correct order; columns out of order go to the end.
    var colModelConfig = [];
    var columns = this.columns;

    Ext.each(this.columnsOrder, function(c) {
      var mainColConfig;
      Ext.each(this.columns, function(oc) {
        if (c.name === oc.name) {
          mainColConfig = Ext.apply({}, oc);
          return false;
        }
      });

      colModelConfig.push(Ext.apply(mainColConfig, c));
    }, this);

    // We don't need original columns any longer
    delete this.columns;

    // ... instead, define own column model
    this.columns = colModelConfig;

    // data store
    this.store = this.buildStore();

    // load inline data if available
    if (this.inlineData) this.store.loadRawData(this.inlineData);

    // Cell editing
    if (!this.prohibitUpdate && this.enableEditInline) {
      this.plugins.push(Ext.create('Ext.grid.plugin.CellEditing', {pluginId: 'celleditor'}));
    }

    // Toolbar
    this.dockedItems = this.dockedItems || [];
    if (this.enablePagination) {
      this.dockedItems.push({
        xtype: 'pagingtoolbar',
        dock: 'bottom',
        store: this.store,
        items: this.bbar && ["-"].concat(this.bbar) // append the passed bbar
      });
    } else if (this.bbar) {
      this.dockedItems.push({
        xtype: 'toolbar',
        dock: 'bottom',
        items: this.bbar
      });
    }

    delete this.bbar;

    this.callParent();

    // Context menu
    if (this.contextMenu) {
      this.on('itemcontextmenu', this.onItemContextMenu, this);
    }

    // Disabling/enabling editInForm button according to current selection
    if (this.enableEditInForm && !this.prohibitUpdate) {
      this.getSelectionModel().on('selectionchange', function(selModel, selected){
        var disabled;
        if (selected === undefined || selected.length === 0) { // empty?
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

    // Process selectionchange event to enable/disable actions
    this.getSelectionModel().on('selectionchange', function(selModel){
      if (this.actions.del) this.actions.del.setDisabled(!selModel.hasSelection() || this.prohibitDelete);
      if (this.actions.edit) this.actions.edit.setDisabled(selModel.getCount() != 1 || this.prohibitUpdate);
    }, this);

    // WIP: GridView
    this.getView().getRowClass = this.defaultGetRowClass;

    // When starting editing as assocition column, pre-load the combobox store from the meta column, so that we don't see the real value of this cell (the id of the associated record), but rather the associated record by the configured method.
    this.on('beforeedit', function(editor, e){
      if (e.column.assoc && e.record.get('meta')) {
        var c = e.column,
        combo = c.getEditor(),
        store = combo.store,
        id = e.record.get(e.field);

        // initial load of 1 single record for the combobox store, which contains the display text (stored in the meta field) for the current value
        if (id && -1 == store.find('value', id)) {
          store.loadData([[e.record.get(e.field), e.record.get('meta').associationValues[e.field]]], true);
        }

      }
    }, this);

    this.on('afterlayout', function() {
      // Persistence-related events (afterrender to avoid blank event firing on render)
      if (this.persistence) {
        // Inform the server part about column operations
        this.on('columnresize', this.onColumnResize, this);
        this.on('columnmove', this.onColumnMove, this);
        this.on('columnhide', this.onColumnHide, this);
        this.on('columnshow', this.onColumnShow, this);
      }
    }, this);

    if(this.getStore().autoSync){
      // if autoSync is enabled, cancel event and call onApply() instead
      this.getStore().on('beforesync', function(){
        this.onApply();
        return false;
      }, this);
    }

    // If edit in form is enabled, but edit in cell is disabled, change double-click to edit in form
    if (this.enableEditInForm && !this.enableEditInline) {
      this.on('itemdblclick', function(view, record) {
        this.onEditInForm();
      }, this);
    }
    if(this.rememberSelection && this.refreshSelection){
      this.getStore().on('beforeload', this.rememberSelection, this);
      this.getView().on('refresh', this.refreshSelection, this);
    }
    // In EXT JS 4.1 the filters object isn't initialized
    if (this.filters === undefined){
      view = this.getView();
      view.initFeatures();
      Ext.each(view.features, function(item, index, allItems){
        if (item.ftype && item.ftype == 'filters'){
          f = item;
        }
      });
      if(f.filters === undefined || f.filters.items.length == 0){
        f.createFilters();
      }
    }else{
      this.filters.createFilters();
    }
  },

  processColumns: function() {
    this.fields = [];

    // Run through columns and set up different configuration for each
    Ext.each(this.columns, function(c, i){

      this.normalizeRenderer(c);

      // Build the field configuration for this column
      var fieldConfig = {name: c.name, defaultValue: c.defaultValue, useNull: true}; // useNull is needed to not convert nils to 0 in associations!

      if (c.name !== 'meta') fieldConfig.type = this.fieldTypeForAttrType(c.attrType); // field type (grid editors need this to function well)

      if (c.attrType == 'datetime') {
        fieldConfig.dateFormat = 'Y-m-d H:i:s'; // set the format in which we receive datetime from the server (so that the model can parse it)

        // While for 'date' columns the renderer is set up automatically (through using column's xtype), there's no appropriate xtype for our custom datetime column.
        // Thus, we need to set the renderer manually.
        // NOTE: for Ext there's no distinction b/w date and datetime; date fields can include time.
        if (!c.renderer) {
          // format in which the data will be rendered; if c.format is nil, Ext.Date.defaultFormat extended with time will be used
          c.renderer = Ext.util.Format.dateRenderer(c.format || Ext.Date.defaultFormat + " H:i:s");
        }
      };

      // because checkcolumn doesn't care about editor (not) being set, we need to explicitely set readOnly here
      if (c.xtype == 'checkcolumn' && !c.editor) {
        c.readOnly = true;
      }

      this.fields.push(fieldConfig);

      // We will not use meta columns as actual columns (not even hidden) - only to create the records
      if (c.meta) {
        this.metaColumn = c;
        return;
      }

      // Set rendeder for association columns (the one displaying associations by the specified method instead of id)
      if (c.assoc) {
        // Editor for association column
        c.editor = Ext.apply({
          name: c.name
        }, c.editor);

        // Renderer for association column
        this.normalizeAssociationRenderer(c);
      }

      if (c.editor) {
        Ext.applyIf(c.editor, {selectOnFocus: true, parentId: this.id});
      }

      // Setting the default filter type
      if (c.filterable != false && !c.filter) {
        c.filter = {type: c.assoc ? 'string' : this.fieldTypeForAttrType(c.attrType)};
      }

      // setting dataIndex
      c.dataIndex = c.name;

    }, this);
  },

  buildStore: function() {
    var store = Ext.create('Ext.data.Store', Ext.apply({
      model: this.id,
      proxy: this.buildProxy(),
      pruneModifiedRecords: true,
      remoteSort: true,
      pageSize: this.rowsPerPage,
      autoLoad: !this.loadInlineData
    }, this.dataStore));

    delete this.dataStore;

    return store;
  },

  buildProxy: function() {
    // DirectProxy that uses our Ext.direct provider
    return Ext.create('Ext.data.proxy.Direct', {
      directFn: Netzke.providers[this.id].getData,
      reader: this.buildReader(),
      listeners: {
        exception: {
          fn: this.loadExceptionHandler,
          scope: this
        },
        load: { // Netzke-introduced event; this will also be fired when an exception occurs.
          fn: function(proxy, response, operation) {
            // besides getting data into the store, we may also get commands to execute
            response = response.result;
            if (response) { // or did we have an exception?
              Ext.each(['data', 'total', 'success'], function(property){delete response[property];});
              this.netzkeBulkExecute(response);
            }
          },
          scope: this
        }
      }
    });
  },

  buildReader: function() {
    return Ext.create('Ext.data.reader.Array', {root: 'data', totalProperty: 'total'});
  },

  fieldTypeForAttrType: function(attrType){
    var map = {
      integer   : 'int',
      decimal   : 'float',
      datetime  : 'date',
      date      : 'date',
      string    : 'string',
      text      : 'string',
      'boolean' : 'boolean'
    };
    return map[attrType] || 'string';
  },

  update: function(){
    this.store.load();
  },

  loadStoreData: function(data){
    var dataRecords = this.getStore().getProxy().getReader().read(data);
    this.getStore().loadData(dataRecords.records);
    Ext.each(['data', 'total', 'success'], function(property){delete data[property];}, this);
    this.netzkeBulkExecute(data);
  },

  // Tries editing the first editable (i.e. not hidden, not read-only) sell
  tryStartEditing: function(r){
    var editableIndex = 0;
    Ext.each(this.initialConfig.columns, function(c){
      // skip columns that cannot be edited
      if (!(c.hidden == true || !c.editor || c.attrType == 'boolean')) {
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

  /*
  Set a renderer that displayes association values instead of association record ID.
  The association values are passed in the meta-column under associationValues hash.
  */
  normalizeAssociationRenderer: function(c) {
    c.scope = this;
    var passedRenderer = c.renderer; // renderer we got from normalizeRenderer
    c.renderer = function(value, a, r, ri, ci){
      var column = this.headerCt.items.getAt(ci),
          editor = column.getEditor && column.getEditor(),
          recordFromStore = editor && editor.isXType('combobox') && editor.getStore().findRecord('value', value),
          renderedValue;

      if (recordFromStore) {
        renderedValue = recordFromStore.get('text');
      } else if (c.assoc && r.get('meta')) {
        renderedValue = r.get('meta').associationValues[c.name] || c.emptyText;
      } else {
        renderedValue = value;
      }

      return passedRenderer ? passedRenderer.call(this, renderedValue) : renderedValue;
    };
  }
}
