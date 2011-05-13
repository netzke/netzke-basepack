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

  // initComponent: function(){
  //   // Ext.netzke.form.CommaListCbg.superclass.initComponent.call(this);
  //   this.callParent();
  //   this.items = [];
  //   Ext.each(this.options, function(o){
  //     this.items.push({boxLabel: o});
  //   }, this);

  //   this.on('change', function(el){
  //     this.hiddenEl.dom.value = this.getValue();
  //   }, this);
  // },

  // onRender: function(ct, position){
  //   // Ext.netzke.form.CommaListCbg.superclass.onRender.call(this, ct, position)
  //   this.callParent( ct, position );
  //   this.hiddenEl = Ext.core.DomHelper.append(ct, {tag:'input', type: 'hidden', name: this.name}, true);

  //   // Don't submit individual checkboxes
  //   this.items.each(function(i){
  //     i.el.dom.removeAttribute("name");
  //   });
  // },

  // getValue: function(){
  //   var checkedBoxes = callParent();
  //   var res = [];
  //   Ext.each(checkedBoxes, function(cb){
  //     res.push(cb.boxLabel);
  //   });
  //   res = res.join(this.separator);
  //   return res;
  // },

  // setValue: function(v){
  //   if (Ext.isString(v)) {
  //     var passedValues = v.split(this.separator);
  //     var values = [];
  //     this.items.each(function(i){
  //       values.push(passedValues.indexOf(i.boxLabel) >= 0);
  //     });
  //     callParent( values );
  //   } else {
  //     callParent();
  //   }
  // },

  // setReadonlyMode: function(onOff) {
  //   this.items.each(function(i){
  //     i.setReadonlyMode(onOff);
  //   });
  // }

});

