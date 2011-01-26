Ext.override(Ext.form.Field, {

  // By calling this, the field is instructed to replace itself with another instance, configured with displayModeConfig
  setDisplayMode: function(onOff){
    if (this.hidden) return;

    var owner = this.ownerCt;
    var newConfig = this.displayModeConfig(onOff);

    var idx = this.removeSelf();
    owner.insert(idx, newConfig);

    this.destroy();
  },

  // Remove self from the container
  removeSelf: function(){
    var idx = this.ownerCt.items.indexOf(this);
    this.ownerCt.remove(this);
    return idx;
  },

  // Config for creating an instance in "displayMode" (if onOff is true), or normal mode (if onOff is false)
  displayModeConfig: function(onOff){
    return Ext.apply(this.initialConfig, onOff ? {xtype: 'displayfield', origXtype: this.xtype, value: this.getValue()} : {xtype: this.origXtype, value: this.getValue()});
  }

});

Ext.override(Ext.netzke.ComboBox, {
  displayModeConfig: function(onOff){
    return Ext.apply(this.initialConfig, onOff ? {xtype: 'displayfield', origXtype: this.xtype, value: this.getRawValue(), origValue: this.getValue()} : {xtype: this.origXtype, value: this.origValue});
  }
});

Ext.override(Ext.netzke.form.NRadioGroup, {
  setDisplayMode: function(onOff){
    this.items.each(function(i){
      i.setDisabled(onOff);
    });
  }
});

Ext.override(Ext.netzke.form.CommaListCbg, {
  setDisplayMode: function(onOff){
    this.items.each(function(i){
      i.setDisabled(onOff);
    });
  }
});

Ext.override(Ext.form.Checkbox, {
  setDisplayMode: function(onOff){
    this.setDisabled(onOff);
  }
});

// Composite field has to take care of its children, by setting them into the "display mode"
Ext.override(Ext.form.CompositeField, {
  displayModeConfig: function(onOff){
    var newItems = [];
    this.items.each(function(i){
      newItems.push(Ext.apply(i.displayModeConfig(onOff)));
      i.destroy();
    });
    return Ext.apply(this.initialConfig, {items: newItems, name: this.name});
  }
});