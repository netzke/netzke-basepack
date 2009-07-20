module Netzke
  module FormPanelExtras
    module JsBuilder
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def js_base_class
          "Ext.FormPanel"
        end

        def js_before_constructor
          <<-JS
          var columns = config.columns;
          var recordFields = [];
          var index = 0;
          Ext.each(columns, function(field){
            recordFields.push({
              name:field.name, 
              mapping:index++
            });
            field.hideLabel = field.hidden; // completely hide columns marked "hidden"
            if (field.xtype == "xcheckbox") field.checked = field.value;
            var extConfig;
            try{
              extConfig = Ext.decode(field.extConfig)
            }
            catch(err){
              extConfig = {}
            }
            delete(field.extConfig);
            Ext.apply(field, extConfig);

            field.parentId = config.id;
            field.fieldConfig = field;
          }, this);
          var Record = Ext.data.Record.create(recordFields);
          this.reader = new Ext.data.RecordArrayReader({root:"data"}, Record);
          JS
        end
        
        def js_after_constructor
          <<-JS
            this.addEvents('apply');
          JS
        end

        def js_default_config
          super.merge({
            :auto_scroll    => true,
            :bbar           => "config.actions".l,
            # :plugins      => "plugins".l,
            :items          => "columns".l,
            :default_type   => 'textfield',
            :body_style     => 'padding:5px 5px 0',
            :label_width    => 150,
            :listeners      => {
      				:afterlayout => {
      				  :fn => "this.afterlayoutHandler".l,
      				  :scope => this
  				    }
				    },
            :defaults       => {
              # :anchor       => '-20', # to leave some space for the scrollbar
              :width => 180,
              :listeners    => {
        				:specialkey => {
        				  :fn => <<-JS.l,
          				  function(field, event){
            					if (event.getKey() == 13) this.apply();
            				}
        				  JS
        				  :scope => this
      				  }
              }
            }
          })
        end
        
        def js_extend_properties
          {
            :set_form_values => <<-JS.l,
              function(values){
                this.form.loadRecord(this.reader.readRecords({data:[values]}).records[0]);
              }
            JS
            # :load_record => <<-JS.l,
            #   function(id, neighbour){
            #     var proxy = new Ext.data.HttpProxy({url:this.initialConfig.api.load});
            #     proxy.load({id:id, neighbour:neighbour}, this.reader, function(data){
            #       if (data){
            #         this.form.loadRecord(data.records[0])
            #       }
            #     }, this)
            #   }
            # JS
            :afterlayout_handler => <<-JS.l,
              function() {
                // Load initial data into the form
                // if (this.initialConfig.recordData){
                //   var record = this.reader.readRecord(this.initialConfig.recordData);
                //   this.form.loadRecord(record);
                // }
              }
            JS
            :refresh=> <<-JS.l,
              function() {
                this.feedback('Implement me!');
              }
            JS
            :previous => <<-JS.l,
              function() {
                var currentId = this.form.getValues().id;
                this.loadRecord(currentId, 'previous');
              }
            JS
            :next => <<-JS.l,
              function() {
                var currentId = this.form.getValues().id;
                this.loadRecord(currentId, 'next');
              }
            JS
            :apply => <<-JS.l,
              function() {
                if (this.fireEvent('apply', this)) {
                  this.submit({data:Ext.encode(this.form.getValues())});
                }
              }
            JS
          }
        end
        
      end
      
    end
  end
end