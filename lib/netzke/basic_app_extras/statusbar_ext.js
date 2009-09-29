Ext.override(Ext.ux.StatusBar, {
  hideBusy : function(){
    return this.setStatus({
      text: this.defaultText,
      iconCls: this.defaultIconCls
    });
  }
});
