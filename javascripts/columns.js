/* Shared column-related functionality, used in Tree and Grid */
Ext.define("Netzke.mixins.Basepack.Columns", {
  nzProcessColumns: function() {
    this.fields = [];

    // Run through columns and set up different configuration for each
    Ext.each(this.columns.items, function(c, i){

      this.nzNormalizeRenderer(c);

      // Build the field configuration for this column
      var fieldConfig = {name: c.name, defaultValue: c.defaultValue, allowNull: true};

      if (c.name !== 'meta') fieldConfig.type = this.nzFieldTypeForAttrType(c.attrType); // field type (grid editors need this to function well)

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

      if (c.attrType == 'date') {
        // If no dateFormat given for date attrType, Timezone translation can subtract zone offset from 00:00:00 causing previous day.
        fieldConfig.dateFormat = 'Y-m-d';
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
        if (c.editor) c.editor = Ext.apply({ name: c.name }, c.editor);

        // Renderer for association column
        this.nzNormalizeAssociationRenderer(c);
      }

      if (c.editor) {
        Ext.applyIf(c.editor, {selectOnFocus: true, nzParent: this});
      }

      // Setting the default filter type
      if (c.filterable != false && !c.filter) {
        c.filter = {type: this.nzFilterTypeForAttrType(c.attrType)};
      }

      // setting dataIndex
      c.dataIndex = c.name;

    }, this);

    // Now reorder columns as specified in this.columnsOrder
    this.orderColumns();
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

    // ... instead, define own column model
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
  nzNormalizeRenderer: function(c) {
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
  nzNormalizeAssociationRenderer: function(c) {
    var passedRenderer = c.renderer, // renderer we got from nzNormalizeRenderer
        metaData, assocValue;
    c.scope = this;
    c.renderer = function(value, a, r, ri, ci, store, view){
      var column = view.headerCt.items.getAt(ci),
          editor = column.getEditor && column.getEditor(),
          recordFromStore = editor && editor.isXType('combobox') && editor.getStore().findRecord('value', value),
          renderedValue;

      if (recordFromStore) {
        renderedValue = recordFromStore.get('text');
      } else if (metaData = r.get('meta')) {
        assocValue = metaData.associationValues[c.name];
        renderedValue = (assocValue == undefined) ? c.emptyText : assocValue;
      } else {
        renderedValue = value;
      }

      return passedRenderer ? passedRenderer.call(this, renderedValue) : renderedValue;
    };
  },

  nzSaveColumns: function(){
    var cols = [];
    this.getView().getHeaderCt().items.each(function(c){
      cols.push({name: c.name, width: c.width, hidden: c.hidden});
    });

    this.server.saveColumns(cols);
  },

  // Tries editing the first editable (i.e. not hidden, not read-only) sell
  nzTryStartEditing: function(r){
    var column = Ext.Array.findBy(this.columns, function(c){
      return !(c.hidden || c.readOnly || c.attrType == 'boolean')
    });

    if (column) {this.getPlugin('celleditor').startEdit(r, column);}
  },

  nzFilterTypeForAttrType: function(attrType){
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
    return map[attrType] || 'string';
  },

  nzFieldTypeForAttrType: function(attrType){
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
    return map[attrType] || 'string';
  }
});
