/* Shared column-related functionality, used in Tree and Grid */
Ext.define("Netzke.Grid.Columns", {
  netzkeProcessColumns: function() {
    this.fields = [];

    // Run through columns and set up different configuration for each
    Ext.each(this.columns.items, function(c){
      this.netzkeNormalizeRenderer(c);
      this.fields.push(this.netzkeExtractFieldConfig(c));

      // We will not use meta columns as actual columns (not even hidden) - only to create the records
      if (!c.meta) {
        this.netzkeExtendColumnConfig(c);
      }
    }, this);

    // Now reorder columns as specified in this.columnsOrder
    this.orderColumns();
  },

  netzkeExtractFieldConfig: function(c){
    // Build the field configuration for this column
    var fieldConfig = {name: c.name, defaultValue: c.defaultValue, allowNull: true};

    if (!c.meta) fieldConfig.type = this.netzkeFieldTypeForAttrType(c.type); // field type (grid editors need this to function well)

    if (c.type == 'datetime') {
      fieldConfig.dateFormat = 'Y-m-d H:i:s'; // set the format in which we receive datetime from the server (so that the model can parse it)

      // While for 'date' columns the renderer is set up automatically (through using column's xtype), there's no appropriate xtype for our custom datetime column.
      // Thus, we need to set the renderer manually.
      // NOTE: for Ext there's no distinction b/w date and datetime; date fields can include time.
      if (!c.renderer) {
        // format in which the data will be rendered; if c.format is nil, Ext.Date.defaultFormat extended with time will be used
        c.renderer = Ext.util.Format.dateRenderer(c.format || Ext.Date.defaultFormat + " H:i:s");
      }
    };

    if (c.type == 'date') {
      // If no dateFormat given for date type, Timezone translation can subtract zone offset from 00:00:00 causing previous day.
      fieldConfig.dateFormat = 'Y-m-d';
    };

    return fieldConfig;
  },

  netzkeExtendColumnConfig: function(c){
    // because checkcolumn doesn't care about editor (not) being set, we need to explicitely set readOnly here
    // if (c.xtype == 'checkcolumn' && !c.editor) {
    //   c.readOnly = true;
    // }

    // Set rendeder for association columns (the one displaying associations by the specified method instead of id)
    if (c.assoc) {
      // Editor for association column
      if (c.editor) c.editor = Ext.apply({ name: c.name }, c.editor);

      // Renderer for association column
      this.netzkeNormalizeAssociationRenderer(c);
    }

    if (c.editor) {
      Ext.applyIf(c.editor, {selectOnFocus: true, netzkeParent: this});
    }

    // Setting the default filter type
    if (c.filterable != false && !c.filter) {
      c.filter = {type: this.netzkeFilterTypeForAttrType(c.type)};
    }

    // setting dataIndex
    c.dataIndex = c.name;
  },

  // Build column model config with columns in the correct order; columns out of order go to the end.
  orderColumns: function(){
    var colModelConfig = [];

    Ext.each(this.columnsOrder, function(c) {
      var mainColConfig;

      Ext.each(this.columns.items, function(oc) {
        if (c.name === oc.name) {
          mainColConfig = Ext.apply({}, oc);
          return false;
        }
      });

      colModelConfig.push(Ext.apply(mainColConfig, c));
    }, this);

    // We don't need original columns any longer
    delete this.columns.items;

    // ... instead, use own column model
    this.columns.items = colModelConfig;
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
  netzkeNormalizeRenderer: function(c) {
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
  netzkeNormalizeAssociationRenderer: function(c) {
    var passedRenderer = c.renderer, // renderer we got from netzkeNormalizeRenderer
        assocValue;
    c.scope = this;
    c.renderer = function(value, a, r, ri, ci, store, view){
      var column = view.headerCt.items.getAt(ci),
          editor = column.getEditor && column.getEditor(),
          recordFromStore = editor && editor.isXType('combobox') && editor.getStore().findRecord('value', value),
          renderedValue;

      if (recordFromStore) {
        renderedValue = recordFromStore.get('text');
      } else if ((assocValue = (r.get('association_values') || {})[c.name]) !== undefined) {
        renderedValue = (assocValue == undefined) ? c.emptyText : assocValue;
      } else {
        renderedValue = value;
      }

      return passedRenderer ? passedRenderer.call(this, renderedValue) : renderedValue;
    };
  },

  netzkeSaveColumns: function(){
    var cols = [];
    this.getView().getHeaderCt().items.each(function(c){
      cols.push({name: c.name, width: c.width, hidden: c.hidden});
    });

    this.server.saveColumns(cols);
  },

  // Tries editing the first editable (i.e. not hidden, not read-only) sell
  netzkeTryStartEditing: function(r){
    var column = Ext.Array.findBy(this.columns, function(c){
      return !(c.hidden || c.readOnly || c.type == 'boolean')
    });

    if (column) {this.getPlugin('celleditor').startEdit(r, column);}
  },

  netzkeFilterTypeForAttrType: function(type){
    var map = {
      integer   : 'number',
      decimal   : 'number',
      float     : 'number',
      datetime  : 'date',
      date      : 'date',
      string    : 'string',
      text      : 'string',
      'boolean' : 'boolean'
    };
    return map[type] || 'string';
  },

  netzkeFieldTypeForAttrType: function(type){
    var map = {
      integer   : 'int',
      decimal   : 'float',
      float     : 'float',
      datetime  : 'date',
      date      : 'date',
      string    : 'string',
      text      : 'string',
      'boolean' : 'boolean'
    };
    return map[type] || 'string';
  }
});
