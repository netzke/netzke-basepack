Ext.ns("Ext.netzke.form");

/*
A very simple CheckboxGroup extension, which serializes its checkboxes' "boxLabel" attributes into a string.
Config options:
* separator - separator of values in the string (defaults to ",")
* options - all checkboxes, by boxLabel, e.g.: ["Cool", "To read", "Important"]
*/
Ext.define('Ext.netzke.form.CommaListCbg', {
  extend: 'Ext.form.CheckboxGroup',
  alias: 'widget.commalistcbg',
  separator: ",",

  initComponent: function(){
    this.items = [];
    Ext.each(this.options, function(o){
      this.items.push({ boxLabel: o, displayOnly:true });
    }, this);

    this.callParent();
  },

  getSubmitData: function(){
    var res = [];
    Ext.each(this.getChecked(), function( item ){ res.push( item.boxLabel ) });
    res = res.join(this.separator);
    var o = {};
    o[this.name]=res;
    return o;
  },

  setValue: function(v){
    if (Ext.isString(v)) {
      var passedValues = v.split(this.separator);
      this.items.each(function(i){
        i.setValue( passedValues.indexOf(i.boxLabel) >= 0 );
      });
    // we can alse set values the Ext way
    } else {
      this.callParent(arguments);
    }
  },

  setReadonlyMode: function(onOff) {
    this.items.each(function(i){
      i.setReadonlyMode(onOff);
    });
  }

});

