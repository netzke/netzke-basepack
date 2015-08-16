// ComboBox that gets options from the server (used in both grids and panels)
Ext.define('Ext.netzke.ComboBox', {
  extend        : 'Ext.form.field.ComboBox',
  alias         : 'widget.netzkeremotecombo',
  valueField    : 'value',
  displayField  : 'text',
  triggerAction : 'all',
  forceSelection: true,

  initComponent : function(){
    var parent = this.netzkeParent || this.findParentBy(function(c) { return c.isNetzke; }),
      modelName = parent.id + "_" + this.name;

    if (this.blankLine == undefined) this.blankLine = "---";

    if (!Netzke.isModelDefined(modelName)) {
      Ext.define(Netzke.modelName(modelName), {
        extend: 'Ext.data.Model',
        fields: ['value', 'text']
      });
    };

    var store = new Ext.data.Store({
      model: Netzke.modelName(modelName),
      proxy: {
        type: 'direct',
        directFn: parent.netzkeGetDirectFunction("getComboboxOptions"),
        reader: {
          type: 'array',
          rootProperty: 'data'
        }
      }
    });

    store.on('beforeload', function(self, op) {
      op.setParams(Ext.apply(op.getParams(), {attr: this.name}));
    }, this);

    // insert a selectable "blank line" which allows to remove the associated record
    if (this.blankLine) {
      store.on('load', function(self, params) {
        // append a selectable "empty line" which will allow remove the association
        self.add(Ext.create(Netzke.modelName(modelName), {value: -1, text: this.blankLine}));
      }, this);
    }

    // If inline data was passed (TODO: is this actually working?)
    if (this.store) store.loadData({data: this.store});

    this.store = store;

    this.callParent();
  }
});
