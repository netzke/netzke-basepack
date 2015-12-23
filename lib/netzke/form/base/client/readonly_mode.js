// Overrides that implement netzkeSetReadonlyMode for form fields.
//

Ext.form.field.Base.override({
  netzkeSetReadonlyMode: function(onOff){
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

// Also the FieldContainer
Ext.form.FieldContainer.override({
  netzkeSetReadonlyMode: function(onOff){
    this.items.each(function(i){
      i.netzkeSetReadonlyMode(onOff);
    });
  }
});

Ext.form.field.Checkbox.override({
  netzkeSetReadonlyMode: function(onOff){
    this.setDisabled(onOff);
  }
});
