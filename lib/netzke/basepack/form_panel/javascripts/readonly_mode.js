Ext.override(Ext.form.Field, {

  // By calling this, the field is instructed to replace itself with another instance, configured with displayModeConfig
  setReadonlyMode: function(onOff){
    if (this.hidden) return;

    this.setReadOnly(onOff);
    if (onOff) {
      this.addClass("readonly");
      if (this.label) this.label.addClass("readonly");
    } else {
      this.removeClass("readonly");
      if (this.label) this.label.removeClass("readonly");
    }
    // var owner = this.ownerCt;
    // var newConfig = this.readonlyModeConfig(onOff);
    //
    // var idx = this.removeSelf();
    // owner.insert(idx, newConfig);
    //
    // this.destroy();
  },

  // Remove self from the container
  // removeSelf: function(){
  //   var idx = this.ownerCt.items.indexOf(this);
  //   this.ownerCt.remove(this);
  //   return idx;
  // },

  // Config for creating an instance in "displayMode" (if onOff is true), or normal mode (if onOff is false)
  // displayModeConfig: function(onOff){
  //   return Ext.apply(this.initialConfig, onOff ? {xtype: 'displayfield', origXtype: this.xtype, value: this.getValue()} : {xtype: this.origXtype, value: this.getValue()});
  // }

});

// Composite field has to take care of its children, by setting them into the "display mode"
Ext.override(Ext.form.CompositeField, {
  setReadonlyMode: function(onOff){
    this.items.each(function(i){
      i.setReadonlyMode(onOff);
    });
  }
});
