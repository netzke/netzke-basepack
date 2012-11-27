// Overrides that implement setReadonlyMode for form fields.
//

Ext.form.field.Base.override({
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

// Also the FieldContainer
Ext.form.FieldContainer.override({
  setReadonlyMode: function(onOff){
    this.items.each(function(i){
      i.setReadonlyMode(onOff);
    });
  }
});

Ext.form.field.Checkbox.override({
  setReadonlyMode: function(onOff){
    this.setDisabled(onOff);
  }
});
