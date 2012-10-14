// ComboBox that gets options from the server (used in both grids and panels)
Ext.define('Ext.netzke.ComboBox', {
  extend        : 'Ext.form.field.ComboBox',
  alias         : 'widget.netzkeremotecombo',
  valueField    : 'value',
  displayField  : 'text',
  triggerAction : 'all',
  // WIP: Breaking - should not be 'true' if combobox is not editable
  // typeAhead     : true,

  // getDisplayValue: function() {
  //   return this.getValue() == 0 ? this.emptyText : this.callOverridden();
  // },

  initComponent : function(){
    var modelName = this.parentId + "_" + this.name;

    if (this.blankLine == undefined) this.blankLine = "---";

    Ext.define(modelName, {
        extend: 'Ext.data.Model',
        fields: ['value', 'text']
    });

    var store = new Ext.data.Store({
      model: modelName,
      proxy: {
        type: 'direct',
        directFn: Netzke.providers[this.parentId].getComboboxOptions,
        reader: {
          type: 'array',
          root: 'data'
        }
      }
    });

    store.on('beforeload', function(self, params) {
      params.params.column = this.name;
    },this);

    // insert a selectable "blank line" which allows to remove the associated record
    if (this.blankLine) {
      store.on('load', function(self, params) {
        // append a selectable "empty line" which will allow remove the association
        self.add(Ext.create(modelName, {value: -1, text: this.blankLine}));
      }, this);
    }

    // If inline data was passed (TODO: is this actually working?)
    if (this.store) store.loadData({data: this.store});

    this.store = store;

    this.callParent();
  },

});
