{
  bodyStyle     : 'padding:5px 5px 0',
  autoScroll    : true,
  labelWidth    : 150,
  applyMask     : {msg: "Updating..."},

  defaults       : {
    anchor       : '-20', // to leave some space for the scrollbar
    listeners    : {
      // On "return" key, submit the form
      specialkey : {
        fn : function(field, event){
          if (event.getKey() == 13) this.ownerCt.onApply();
        }
      }
    }
  },

  initComponent: function(){
    if (!this.bbar) this.bbar = {xtype: 'toolbar'}; // an empty bbar by default, so that we can dynamically add buttons

    // Now let Ext.form.FormPanel do the rest
    Netzke.classes.Basepack.FormPanel.superclass.initComponent.call(this);

    // Apply event
    this.addEvents('apply');
  },

  afterRender: function(){
    Netzke.classes.Basepack.FormPanel.superclass.afterRender.call(this);

    // render in display mode?
    if (this.locked) this.setDisplayMode(true);
  },

  onEdit: function(){
    this.setDisplayMode(false);
  },

  onCancel: function(){
    this.setDisplayMode(true, true);
  },

  updateToolbar: function(){
    var tbar = this.getBottomToolbar();

    if (this.inDisplayMode) {
      var buttonIndex = tbar.items.findIndex("name", "apply");
      var buttonToRemove = tbar.items.itemAt(buttonIndex);
      if (buttonToRemove) {
        tbar.remove(buttonToRemove);
      }

      var buttonIndex = tbar.items.findIndex("name", "cancel");
      var buttonToRemove = tbar.items.itemAt(buttonIndex);
      if (buttonToRemove) {
        tbar.remove(buttonToRemove);
      }
      tbar.add(this.actions.edit);
    } else {
      var buttonIndex = tbar.items.findIndex("name", "edit");
      var buttonToRemove = tbar.items.itemAt(buttonIndex);
      if (buttonToRemove) {
        tbar.remove(buttonToRemove);
      }
      tbar.insertButton(buttonIndex, this.actions.apply);
      tbar.insertButton(buttonIndex, this.actions.cancel);
    }

    tbar.doLayout();
  },


  onApply: function() {
    if (this.fireEvent('apply', this)) {
      var values = this.getForm().getValues();

      // do not send values from disabled fields and empty values
      for (var fieldName in values) {
        var field = this.getForm().findField(fieldName);
        if (!field || field.disabled) delete values[fieldName];
      }

      if (!this.applyMaskCmp) this.applyMaskCmp = new Ext.LoadMask(this.bwrap, this.applyMask);

      this.applyMaskCmp.show();

      if (this.fileUpload) {
        // Not a Netzke's standard endpoint call, because the form is multipart
        this.getForm().submit({
          url: this.endpointUrl("netzke_submit"),
          params: {
            data: Ext.encode(values)
          },
          failure: function(form, action){
            // It will always be failure, as we don't play along with the Ext success indication (not returning {success: true})
            this.bulkExecute(Ext.decode(action.response.responseText));
            this.fireEvent('submitsuccess');
            if (this.applyMaskCmp) this.applyMaskCmp.hide();
          },
          scope: this
        });
      } else {
        // Submit the data and process the result
        this.netzkeSubmit(Ext.apply((this.baseParams || {}), {data:Ext.encode(values)}), function(result){
          if (result === "ok") {
            this.fireEvent("submitsuccess");
            if (this.mode == "lockable") this.setDisplayMode(true);
          };
          if (this.applyMaskCmp) this.applyMaskCmp.hide();
        }, this);
      }
    }
  },

  setFormValues: function(values){
    var normValues = {};
    for (var key in values) {
      // var normKey = key.replace("_", "__").underscore();
      var normKey = key;
      normValues[normKey] = values[key];
    }
    this.getForm().setValues(normValues);
  },

  setDisplayMode: function(onOff, cancel){
    if (this.inDisplayMode == onOff) return;
    this.getForm().items.each(function(i){i.setDisplayMode(onOff);});
    this.getForm().cleanDestroyed(); // because fields inside of composite fields are not auto-cleaned!
    this.doLayout();
    this.inDisplayMode = onOff;
    this.updateToolbar();
  }

}
