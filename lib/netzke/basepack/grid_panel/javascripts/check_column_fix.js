Ext.override(Ext.ux.CheckColumn, {
  processEvent: function() {
    if (this.editable === false) return false;
    else return this.callOverridden(arguments);
  }
});