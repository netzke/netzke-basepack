Ext.ns("Ext.netzke.form");

/*
A very simple RadioGroup extension.
Config options:
* options - all radio buttons, by boxLabel, e.g.: ["Cool", "To read", "Important"]
*/
Ext.netzke.form.NRadioGroup = Ext.extend(Ext.form.RadioGroup, {
  // defaultType: 'radio',
  // groupCls : 'x-form-radio-group',

  initComponent: function(){
    Ext.netzke.form.NRadioGroup.superclass.initComponent.call(this);

    this.items = [];

    Ext.each(this.options, function(o){
      this.items.push({boxLabel: o, name: this.name, inputValue: o});
    }, this);

    delete this.name;
  }
});

Ext.reg('nradiogroup', Ext.netzke.form.NRadioGroup);
