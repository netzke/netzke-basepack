module Netzke::Widget
  class FormPanel < Base
    module FormPanelJs
      # TODO: automatically add the primary hidden field (if not yet there)
      def js_config
        res = super
        res.merge!(:fields => fields)
        res.merge!(:pri    => data_class.primary_key) if data_class
        res
      end

      module ClassMethods
        def js_base_class
          "Ext.FormPanel"
        end

        def js_properties
          {
            :body_style     => 'padding:5px 5px 0',
            :auto_scroll    => true,
            :label_width    => 150,
            :default_type   => 'textfield',
            
            # This function is recursive, descending into the internals of the static layout
            :detect_fields => <<-END_OF_JAVASCRIPT.l,
              function(fields){
                Ext.each(fields, function(field){
                  if (field.items) {
                    this.detectFields(field.items);
                  } else {
                    if (!field.hidden || field.name == this.pri) {

                      this.recordFields.push({name:field.name, mapping:this.recordIndex++});
                      
                      if (field.name == this.pri) this.primaryPresent = true;
                      
                      if (!this.autoFieldLayout) {
                        // Apply corresponding config from this.fields (which take precedence, thus overriding what's originally
                        // in the code!)
                        // This is where, for example, the field values get set.
                        Ext.apply(field, this.fieldsObject[field.name]);
                      }

                      // apply dynamically defined properties
                      Ext.applyIf(field, {
                        xtype     : this.attrTypeEditorMap[field.attrType || 'string'],
                        fieldLabel: field.fieldLabel || field.label || field.name.humanize(),
                        hideLabel : field.hidden, // completely hide fields marked "hidden"
                        parentId  : this.id,
                        // name      : field.name,
                        value     : field.value || field.defaultValue,
                        checked   : field.attrType == "boolean" ? field.value : null // checkbox state
                      });

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
              }
            END_OF_JAVASCRIPT

            :init_component => <<-END_OF_JAVASCRIPT.l,
              function(){
                this.recordFields = []; // Record
                this.recordIndex = 0;
                
                this.fieldsObject = {};
                Ext.each(this.fields, function(fieldConfig){
                  this.fieldsObject[fieldConfig.name] = fieldConfig;
                  delete fieldConfig.name;
                }, this);
                
                if (!this.items) {
                  this.autoFieldLayout = true;
                  this.items = this.fields;
                }
                  
                this.detectFields(this.items);
                
                if (!this.primaryPresent) {
                  this.recordFields.push({name: this.pri, mapping: this.recordIndex++});
                  this.items.push({hidden: true, name: this.pri, value: this.fieldsObject[this.pri].value});
                }
                
                var Record = Ext.data.Record.create(this.recordFields);
                this.reader = new Ext.data.RecordArrayReader({root:"data"}, Record);
            
                delete this.fields; // we don't need them anymore
            
                // Now let Ext.form.FormPanel do the rest
                #{js_full_class_name}.superclass.initComponent.call(this);
            
                // Apply event
                this.addEvents('apply');
              }
            END_OF_JAVASCRIPT

            :attr_type_editor_map => {
              :integer  => "numberfield",
              :boolean  => "checkbox",
              :decimal  => "numberfield",
              :datetime => "xdatetime",
              :date     => "datefield",
              :string   => "textfield"
            },

            # Defaults for each field
            :defaults       => {
              :anchor       => '-20', # to leave some space for the scrollbar
              # :width => 180, # we do NOT want fixed size because it doesn't look nice when resizing
              :listeners    => {
                # On "return" key, submit the form
        				:specialkey => {
        				  :fn => <<-END_OF_JAVASCRIPT.l
          				  function(field, event){
            					if (event.getKey() == 13) this.ownerCt.onApply();
            				}
        				  END_OF_JAVASCRIPT
      				  }
              }
            },
        
            # :default_column_config => meta_columns.inject({}){ |r, c| r.merge!({
            #   c[:name] => c[:default_value]
            # })},
        
            :set_form_values => <<-END_OF_JAVASCRIPT.l,
              function(values){
                this.form.loadRecord(this.reader.readRecords({data:[values]}).records[0]);
              }
            END_OF_JAVASCRIPT

            :load_record => <<-END_OF_JAVASCRIPT.l,
              function(id, neighbour){
                this.netzkeLoad({id:id});
              }
            END_OF_JAVASCRIPT
        
            # :previous => <<-END_OF_JAVASCRIPT.l,
            #   function() {
            #     var currentId = this.form.getValues().id;
            #     this.loadRecord(currentId, 'previous');
            #   }
            # END_OF_JAVASCRIPT
            # 
            # :next => <<-END_OF_JAVASCRIPT.l,
            #   function() {
            #     var currentId = this.form.getValues().id;
            #     this.loadRecord(currentId, 'next');
            #   }
            # END_OF_JAVASCRIPT
        
            :on_apply => <<-END_OF_JAVASCRIPT.l
              function() {
                if (this.fireEvent('apply', this)) {
                  var values = this.getForm().getValues();
                  for (var k in values) {
                    if (values[k] == "") {delete values[k]}
                  }
                  if (this.fileUpload) {
                    // Not a Netzke's standard API call, because the form is multipart
                    this.getForm().submit({
                      url: this.buildApiUrl("netzke_submit"),
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
              }
            END_OF_JAVASCRIPT
          }
        end
    
      end
    
      def self.included(base)
        base.extend ClassMethods
      end
    
    end
  end
end