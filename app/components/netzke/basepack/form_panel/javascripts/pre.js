/* 
  Static part of GridPanel's JavaScript class.
*/
Netzke.pre.FormPanel = Ext.extend(Ext.form.FormPanel, {
  bodyStyle     : 'padding:5px 5px 0',
  autoScroll    : true,
  labelWidth    : 150,
  
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
      
  initComponent  : function(){
    this.recordFields = []; // Record
    this.recordIndex = 0;
    
    var Record = Ext.data.Record.create(this.recordFields);
    this.reader = new Ext.data.RecordArrayReader({root:"data"}, Record);
    
    // Now let Ext.form.FormPanel do the rest
    Netzke.pre.FormPanel.superclass.initComponent.call(this);

    // Apply event
    this.addEvents('apply');
  },

  onApply         : function() {
    if (this.fireEvent('apply', this)) {
      var values = this.getForm().getValues();
      
      // do not send values from disabled fields
      for (var fieldName in values) {
        var field = this.getForm().findField(fieldName);
        if (!field || field.disabled) delete values[fieldName];
      }
      
      // do not send empty values
      for (var k in values) {
        if (values[k] == "") {delete values[k]}
      }
      
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
          },
          scope: this
        });
      } else {
        // Submit the data and process the result
        this.netzkeSubmit(Ext.apply((this.baseParams || {}), {data:Ext.encode(values)}), function(result){
          if (result === "ok") {this.fireEvent("submitsuccess")};
        }, this);
      }
    }
  },
  
  setFormValues   : function(values){
    var normValues = {};
    for (var key in values) {
      normValues[key.underscore()] = values[key];
    }
    this.getForm().setValues(normValues);
  }
  
});