/* 
  Static part of GridPanel's JavaScript class.
*/
Netzke.pre.FormPanel = Ext.extend(Ext.form.FormPanel, {
  bodyStyle     : 'padding:5px 5px 0',
  autoScroll    : true,
  labelWidth    : 150,
  defaultType   : 'textfield',
  
  attrTypeEditorMap : {
    integer  : "numberfield",
    "boolean": "checkbox",
    decimal  : "numberfield",
    datetime : "xdatetime",
    date     : "datefield",
    string   : "textfield"
  },
  
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
    
    this.fieldsObject = {};
    Ext.each(this.fields, function(fieldConfig){
      this.fieldsObject[fieldConfig.name] = fieldConfig;
    }, this);
    
    if (!this.items) {
      this.autoFieldLayout = true;
      this.items = this.fields;
    }
    
    this.detectFields(this.items);
    
    // If the primary key field is not mentioned in items, add it automatically as a hidden field
    if (!this.primaryPresent && this.model) {
      this.recordFields.push({name: this.pri, mapping: this.recordIndex++});
      
      var priItem = {hidden: true, name: this.pri, value: this.fieldsObject[this.pri].value};
      this.items.push(priItem);
    }
    
    var Record = Ext.data.Record.create(this.recordFields);
    this.reader = new Ext.data.RecordArrayReader({root:"data"}, Record);
    
    delete this.fields; // we don't need them anymore

    // Now let Ext.form.FormPanel do the rest
    Netzke.pre.FormPanel.superclass.initComponent.call(this);

    // Apply event
    this.addEvents('apply');
  },
  
  normalizeField : function(field){
    // apply dynamically defined properties
    if (!this.autoFieldLayout) {
      // Apply corresponding config from this.fields (which take precedence, 
      // thus overriding what's originally in the code!)
      // This is where, for example, the field values get set.
      Ext.apply(field, this.fieldsObject[field.name]);
    }
    
    Ext.applyIf(field, {
      xtype     : this.attrTypeEditorMap[field.attrType || 'string'],
      fieldLabel: field.fieldLabel || field.label || field.name.humanize(),
      hideLabel : field.hidden, // completely hide fields marked "hidden"
      parentId  : this.id,
      // name      : field.name,
      value     : field.value || field.defaultValue,
      checked   : field.attrType == "boolean" ? field.value : null // checkbox state
    });
  },
  
  detectFields  : function(fields){
    Ext.each(fields, function(field){
      if (field.items) {
        this.detectFields(field.items);
      } else {
        if (!field.hidden || field.name == this.pri) {

          this.recordFields.push({name:field.name, mapping:this.recordIndex++});
          
          if (field.name == this.pri) this.primaryPresent = true;
          
          this.normalizeField(field);
          // var defaultColumnConfig = Ext.apply({}, this.defaultColumnConfig);
          // var columnConfig = Ext.apply(defaultColumnConfig, field);
          // 
          // // apply dynamically defined properties
          // Ext.apply(field, {
          //   name: columnConfig.name,
          //   parentId: this.id,
          // });

        }
      }
    }, this);
  },
  
  onApply         : function() {
    if (this.fireEvent('apply', this)) {
      var values = this.getForm().getValues();

      // Delete empty values
      for (var k in values) {
        if (values[k] == "") {delete values[k]}
      }
      
      if (this.fileUpload) {
        // Not a Netzke's standard API call, because the form is multipart
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
    this.getForm().setValues(values);
  },
  
});