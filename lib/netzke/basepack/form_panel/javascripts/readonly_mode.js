Ext.override(Ext.form.Field, {

  // By calling this, the field is instructed to replace itself with another instance, configured with displayModeConfig
  setReadonlyMode: function(onOff){
    if (this.hidden) return;

    if (!this.initialConfig.readOnly) {
      this.setReadOnly(onOff);
    }

    if (onOff) {
      this.addCls("readonly");
      if (this.label) this.label.addCls("readonly");
    } else {
      this.removeCls("readonly");
      if (this.label) this.label.removeCls("readonly");
    }
  }

});

// Composite field has to take care of its children, by setting them into the "display mode"
Ext.override(Ext.form.CompositeField, {
  setReadonlyMode: function(onOff){
    this.items.each(function(i){
      i.setReadonlyMode(onOff);
    });
  }
});

Ext.override(Ext.form.Checkbox, {
  setReadonlyMode: function(onOff){
    this.setDisabled(onOff);
  }
});
