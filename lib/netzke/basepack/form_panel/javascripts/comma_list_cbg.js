Ext.ns("Ext.netzke.form");

/*
A very simple CheckboxGroup extension, which serializes its checkboxes' "boxLabel" attributes into a string.
Config options:
* separator - separator of values in the string (defaults to ",")
* options - all checkboxes, by boxLabel, e.g.: ["Cool", "To read", "Important"]
*/
Ext.netzke.form.CommaListCbg = Ext.extend(Ext.form.CheckboxGroup, {
  separator: ",",

  initComponent: function(){
    Ext.netzke.form.CommaListCbg.superclass.initComponent.call(this);

    this.items = [];
    Ext.each(this.options, function(o){
      this.items.push({boxLabel: o});
    }, this);

    this.on('change', function(el){
      this.hiddenEl.dom.value = this.getValue();
    }, this);
  },

  onRender: function(ct, position){
    Ext.netzke.form.CommaListCbg.superclass.onRender.call(this, ct, position)
    this.hiddenEl = Ext.DomHelper.append(ct, {tag:'input', type: 'hidden', name: this.name}, true);

    // Don't submit individual checkboxes
    this.items.each(function(i){
      i.el.dom.removeAttribute("name");
    });
  },

  getValue: function(){
    var checkedBoxes = Ext.netzke.form.CommaListCbg.superclass.getValue.call(this);
    var res = [];
    Ext.each(checkedBoxes, function(cb){
      res.push(cb.boxLabel);
    });
    res = res.join(this.separator);
    return res;
  },

  setValue: function(v){
    if (Ext.isString(v)) {
      var passedValues = v.split(this.separator);
      var values = [];
      this.items.each(function(i){
        values.push(passedValues.indexOf(i.boxLabel) >= 0);
      });
      Ext.netzke.form.CommaListCbg.superclass.setValue.call(this, values);
    } else {
      Ext.netzke.form.CommaListCbg.superclass.setValue.call(this, arguments);
    }
  },

  setReadonlyMode: function(onOff) {
    this.items.each(function(i){
      i.setReadonlyMode(onOff);
    });
  }

});

Ext.reg('commalistcbg', Ext.netzke.form.CommaListCbg);
