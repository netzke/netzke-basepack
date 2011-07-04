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

    // Custom error reader. We don't use it to process form values, but rather to normalize the response from the server in case of "real" (iframe) form submit.
    ErrorReader = function(){};

    ErrorReader.prototype.read = function(xhr) {
      var unescapeHTML = function(str) {
        return str.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g,'&');
      }
      xhr.responseText = unescapeHTML(xhr.responseText.replace(/<pre.*?>/, "").replace("</pre>", ""));
      return {records: [], success: true};
    };

    this.initialConfig.errorReader = new ErrorReader();

    // Now let Ext.form.FormPanel do the rest
    Netzke.classes.Basepack.FormPanel.superclass.initComponent.call(this);

    // To inform the parent about the apply event
    this.addEvents('apply');
  },

  afterRender: function(){
    Netzke.classes.Basepack.FormPanel.superclass.afterRender.call(this);

    // have a record to be displayed?
    if (this.record) { this.setFormValues(this.record); }

    // render in display mode?
    if (this.locked) this.setReadonlyMode(true);
  },

  onEdit: function(){
    this.setReadonlyMode(false);
  },

  onCancel: function(){
    this.setReadonlyMode(true, true);
  },

  updateToolbar: function(){
    var tbar = this.getBottomToolbar();

    if (this.inReadonlyMode) {
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
      var values = this.getForm().getFieldValues();

      for (var fieldName in values) {
        var field = this.getForm().findField(fieldName);

        // TODO: move the following checks to the server side (through the :display_only option)

        // do not submit values from disabled fields
        if (!field || field.disabled) delete values[fieldName];

        // do not submit values from read-only association fields
        if (field
          && field.name
          && field.name.indexOf("__") !== -1
          && (field.readOnly || !field.getStore)
          && (!field.nestedAttribute) // except for "nested attributes"
        ) delete values[fieldName];

        // do not submit values from displayfields
        if (field.isXType('displayfield')) delete values[fieldName];

        // do not submit displayOnly fields
        if (field.displayOnly) delete values[fieldName];
      }

      // apply mask
      if (!this.applyMaskCmp) this.applyMaskCmp = new Ext.LoadMask(this.bwrap, this.applyMask);
      this.applyMaskCmp.show();

      // We must use a different approach when the form is multipart, as we can't use the endpoint
      if (this.fileUpload) {
        this.getForm().submit({ // normal submit
          url: this.endpointUrl("netzke_submit"),
          params: {
            data: Ext.encode(values) // here are the correct values that may be different from display values
          },
          failure: function(form, action){
            if (this.applyMaskCmp) this.applyMaskCmp.hide();
          },
          success: function(form, action) {
            try {
              var respObj = Ext.decode(action.response.responseText);
              var success = respObj.success;
              delete respObj.success;
              this.bulkExecute(respObj);
              if (success) this.fireEvent('submitsuccess');
            }
            catch(e) {
              Ext.Msg.alert('File upload error', action.response.responseText);
            }
            if (this.applyMaskCmp) this.applyMaskCmp.hide();
          },
          scope: this
        });
      } else {
        this.netzkeSubmit(Ext.apply((this.baseParams || {}), {data:Ext.encode(values)}), function(success){
          if (success) {
            this.fireEvent("submitsuccess");
            if (this.mode == "lockable") this.setReadonlyMode(true);
          };
          if (this.applyMaskCmp) this.applyMaskCmp.hide();
        }, this);
      }
    }
  },

  setFormValues: function(values){
    var assocValues = values._meta.associationValues || {};
    for (var assocFieldName in assocValues) {
      var assocField = this.find('name', assocFieldName)[0];
      if (assocField.getStore) {
        assocField.getStore().loadData({data: [[values[assocFieldName], assocValues[assocFieldName]]]});
        delete assocField.lastQuery; // force loading the store next time user clicks the trigger
      } else {
        assocField.setValue(assocValues[assocFieldName]);
        delete values[assocFieldName]; // we don't want this to be set once more below with setValues()
      }
    }

    this.getForm().setValues(values);
  },

  setReadonlyMode: function(onOff, cancel){
    if (this.inReadonlyMode == onOff) return;
    this.getForm().items.each(function(i){i.setReadonlyMode(onOff);});
    // this.getForm().cleanDestroyed(); // because fields inside of composite fields are not auto-cleaned!
    this.doLayout();
    this.inReadonlyMode = onOff;
    this.updateToolbar();
  },

  // recursively extract field names
  extractFields: function(items){
    Ext.each(items, function(i){
      if (i.items) {this.extractFields(i.items);}
      else if (i.name) {this.fieldNames.push(i.name);}
    }, this);
  },

  applyFormErrors: function(errors) {
    var field;
    Ext.iterate(errors, function(fieldName, message){
      fieldName = fieldName.underscore();
      if ( field = this.getForm().findField(fieldName) || this.getForm().findField(fieldName.replace(/([a-z]+)([0-9])/g, '$1_$2'))) {
        field.markInvalid(message.join('<br/>'));
      }
    }, this);
  }

}
