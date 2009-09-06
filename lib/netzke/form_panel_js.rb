module Netzke
  module FormPanelJs
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def js_base_class
        "Ext.FormPanel"
      end

      def js_extend_properties
        {
          :body_style     => 'padding:5px 5px 0',
          :auto_scroll    => true,
          :label_width    => 150,
          :default_type   => 'textfield',
          # :label_align => 'top',

          :init_component => <<-END_OF_JAVASCRIPT.l,
            function(){
              var recordFields = []; // Record
              this.items = [];
              var index = 0;
              
              // Process columns
              Ext.each(this.clmns, function(field){
                if (typeof field == 'string') field = {name:field}; // normalize field
                if (!field.hidden || field.name == 'id') {
                  recordFields.push({name:field.name, mapping:index++});

                  var defaultColumnConfig = Ext.apply({}, this.defaultColumnConfig);
                  var columnConfig = Ext.apply(defaultColumnConfig, field);

                  // apply dynamically defined properties
                  Ext.apply(columnConfig, {
                    fieldLabel: columnConfig.fieldLabel || columnConfig.name.humanize(),
                    hideLabel: columnConfig.hidden, // completely hide fields marked "hidden"
                    parentId: this.id,
                    name: columnConfig.name,
                    checked: columnConfig.xtype == "xcheckbox" ? columnConfig.value : null // checkbox state
                  });

                  this.items.push(columnConfig);
                }
              }, this);
              
              var Record = Ext.data.Record.create(recordFields);
              this.reader = new Ext.data.RecordArrayReader({root:"data"}, Record);
              
              delete this.clmns; // we don't need them anymore
              
              // Now let Ext.form.FormPanel do the rest
              Ext.netzke.cache.FormPanel.superclass.initComponent.call(this);
              
              // Apply event
              this.addEvents('apply');
            }
          END_OF_JAVASCRIPT

          # Defaults for each field
          :defaults       => {
            # :anchor       => '-20', # to leave some space for the scrollbar
            :width => 180,
            :listeners    => {
              # On "return" key, submit the form
      				:specialkey => {
      				  :fn => <<-END_OF_JAVASCRIPT.l
        				  function(field, event){
          					if (event.getKey() == 13) this.ownerCt.apply();
          				}
      				  END_OF_JAVASCRIPT
    				  }
            }
          },
          
          :default_column_config => config_columns.inject({}){ |r, c| r.merge!({
            c[:name] => c[:default]
          }) },
          
          :set_form_values => <<-END_OF_JAVASCRIPT.l,
            function(values){
              this.form.loadRecord(this.reader.readRecords({data:[values]}).records[0]);
            }
          END_OF_JAVASCRIPT

          :load_record => <<-END_OF_JAVASCRIPT.l,
            function(id, neighbour){
              this.load({id:id});
              // var proxy = new Ext.data.HttpProxy({url:this.initialConfig.api.load});
              // proxy.load({id:id, neighbour:neighbour}, this.reader, function(data){
              //   if (data){
              //     this.form.loadRecord(data.records[0])
              //   }
              // }, this)
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
          
          :apply => <<-END_OF_JAVASCRIPT.l
            function() {
              if (this.fireEvent('apply', this)) {
                var values = this.form.getValues();
                for (var k in values) {
                  if (values[k] == "") {delete values[k]}
                }
                this.submit(Ext.apply((this.baseParams || {}), {data:Ext.encode(values)}));
              }
            }
          END_OF_JAVASCRIPT
        }
      end
      
    end
  end
end