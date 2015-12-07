{
  bodyStyle     : 'padding:5px 5px 0',
  autoScroll    : true,
  fieldDefaults : { labelWidth : 150 },

  defaults       : {
    anchor       : '-20' // to leave some space for the scrollbar
  },

  initComponent: function(){
    // passing config options to BasicForm is possible via initialConfig only
    // see Ext.form.Panel documentation
    this.initialConfig = {
      // form tracks it's default field values so they can be reset()
      trackResetOnLoad: true,
    }

    // if (!this.bbar && !this.readOnly) this.bbar = {xtype: 'toolbar'}; // an empty bbar by default, so that we can dynamically add buttons

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

    // Now let Ext.form.Form do the rest
    this.callParent(arguments);

    if (this.applyOnReturn) {
      Ext.each(this.query('field'), function(field) {
        field.on('specialkey', function(field, event) {
          if (event.getKey() == 13) this.up('form').onApply();
        });
      });
    }
  },

  afterRender: function(){
    this.callParent();

    // have a record to be displayed?
    if (this.record) { this.setFormValues(this.record); }

    // render in display mode?
    if (this.locked || this.readOnly) this.setReadonlyMode(true);
  },

  onEdit: function(){
    this.setReadonlyMode(false);
  },

  onCancel: function(){
    this.getForm().reset();
    this.setReadonlyMode(true, true);
  },

  updateToolbar: function(){
    var tbar = this.child('toolbar');
    if (!tbar) return;

    if ( this.inReadonlyMode ) {
      //   if the form in readonly mode, remove "Apply" and "Cancel"
      //   buttons from toolbar and add "Edit" button
      var buttonToRemove = tbar.child("button[name='apply']");
      if ( buttonToRemove ) {
        tbar.remove( buttonToRemove );
      }

      var buttonToRemove = tbar.child("button[name='cancel']");
      if ( buttonToRemove ) {
        tbar.remove( buttonToRemove );
      }

      tbar.add( this.actions.edit );

    } else {
      // if the form editable, remove "edit" button and
      // insert "apply" and "cancel" instead

      var buttonIndex = tbar.items.findIndex("name", "edit");
      var buttonToRemove = tbar.items.getAt(buttonIndex);
      if (buttonToRemove) {
        tbar.remove(buttonToRemove);
      }
      tbar.insert( buttonIndex, this.actions.cancel );
      tbar.insert( buttonIndex, this.actions.apply );
    }

    tbar.doLayout();
  },

  onApply: function() {
    if (this.fireEvent('apply', this)) {
      var values = this.getForm().getValues();
      for (var fieldName in values) {
        var field = this.getForm().findField(fieldName);

        // TODO: move the following checks to the server side (through the :display_only option)

        // do not submit values from disabled fields
        if (!field || field.disabled) {
          delete values[fieldName];
        }

        // do not submit values from read-only association fields
        if (field
          && field.name.indexOf("__") !== -1
          && (field.readOnly || !field.isXType('combobox'))
          && (!field.nestedAttribute) // except for "nested attributes"
        ) {
          delete values[fieldName];
        }

        // do not submit values from displayfields
        if (field.isXType('displayfield')) {
          delete values[fieldName];
        }

        // do not submit displayOnly fields
        if (field.displayOnly) {
          delete values[fieldName];
        }
      }

      // loading mask
      this.setLoading(true);

      // We must use a different approach when the form is multipart, as we can't use the endpoint
      if (this.getForm().hasUpload()) {
        this.getForm().submit({ // normal submit
          url: this.nzEndpointUrl("submit"),
          params: {
            data: Ext.encode(values) // here are the correct values that may be different from display values
          },
          failure: function(form, action){
            var respObj = Ext.decode(action.response.responseText);
            delete respObj.success;
            this.nzBulkExecute(respObj);
            this.setLoading(false);
          },
          success: function(form, action) {
            var respObj = Ext.decode(action.response.responseText);
            delete respObj.success;
            this.nzBulkExecute(respObj);
          },
          scope: this
        });
      } else {
        this.server.submit(Ext.apply((this.baseParams || {}), { data:Ext.encode(values) }), function(){ this.setLoading(false); });
      }
    }
    this.fireEvent('afterApply', this);
  },

  // called from the server
  onSubmitSuccess: function() {
    this.fireEvent("submitsuccess");
    if (this.mode == "lockable") this.setReadonlyMode(true);
    this.setLoading(false);
  },

  setFormValues: function(values){
    var assocValues = values.meta.associationValues || {};
    for (var assocFieldName in assocValues) {

      var assocField = this.getForm().getFields().filter('name', assocFieldName).first();
      if (assocField.isXType('combobox')) {
        // HACK: using private property 'store' here!
        assocField.store.loadData([[values[assocFieldName], assocValues[assocFieldName]]]);
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
    this.getForm().getFields().each(function(i){
      if (i.setReadonlyMode) i.setReadonlyMode(onOff);
    });

    // this.getForm().cleanDestroyed(); // because fields inside of composite fields are not auto-cleaned!
    this.doLayout();
    this.inReadonlyMode = onOff;
    if (this.mode == "lockable") this.updateToolbar();
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
      if ( field = this.getForm().findField(fieldName) ||
           this.getForm().findField(fieldName.replace(/([a-z]+)([0-9])/g, '$1_$2')) ||
           this.getForm().getFields().findBy(function(f){ return fieldName == f.getName().replace(/(.+)__.+/g, '$1'); }) ||
           this.getForm().getFields().findBy(function(f){
             str = f.getName().camelize();
             first = str.substring(0,1);
             matchingName = (first.toLowerCase()+str.substring(1)).underscore();
             return fieldName == matchingName;
           })
      ) {
        field.markInvalid(message.join('<br/>'));
      }
    }, this);
  }
}
