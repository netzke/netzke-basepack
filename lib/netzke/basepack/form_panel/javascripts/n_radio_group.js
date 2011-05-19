Ext.ns("Ext.netzke.form");
/*
A very simple RadioGroup extension.
Config options:
* options:
  1) all radio buttons, by boxLabel, e.g.: ["Cool", "To read", "Important"]
  2) array of arrays in format [value, label], e.g.: [[1, "Good"], [2, "Average"], [3, "Poor"]]
*/
Ext.define('Ext.netzke.form.NRadioGroup', {
  extend: 'Ext.form.RadioGroup',
  alias:  'widget.nradiogroup',
  initComponent: function(){
    this.callParent();

    this.items = [];

    Ext.each(this.options, function(o){
      if (Ext.isArray(o)){
        this.items.push({boxLabel: o[1], name: this.name, inputValue: o[0]});
      } else {
        this.items.push({boxLabel: o, name: this.name, inputValue: o});
      }
    }, this);

    // delete this.name;
  },

  getValue: function() {
    var value;
    this.items.each(function(i) {
      value = i.inputValue;
      return !i.getValue();
    });
    return value;
  },

  setReadonlyMode: function(onOff) {
    this.items.each(function(i){
      i.setReadonlyMode(onOff);
    });
  }
});

