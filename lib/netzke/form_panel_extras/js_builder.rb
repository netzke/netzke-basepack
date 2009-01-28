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
          var fields = config.fields; // TODO: remove hidden fields
          var recordFields = [];
          var index = 0;
          Ext.each(config.fields, function(field){recordFields.push({name:field.name, mapping:index++})});
          var Record = Ext.data.Record.create(recordFields);
          this.reader = new Ext.data.RecordArrayReader({}, Record);
          JS
        end

        def js_default_config
          super.merge({
            :auto_scroll    => true,
            :bbar           => "config.actions".l,
            # :plugins      => "plugins".l,
            :items          => "fields".l,
            :default_type   => 'textfield',
            :body_style     => 'padding:5px 5px 0',
            :label_width    => 150,
            :listeners      => {:afterlayout => {:fn => "this.afterlayoutHandler".l, :scope => this}},

            #custom configs
            :auto_load_data => true,
          })
        end
        
        def js_extend_properties
          {
            :load_record => <<-JS.l,
              function(id, neighbour){
                var proxy = new Ext.data.HttpProxy({url:this.initialConfig.interface.load});
                proxy.load({id:id, neighbour:neighbour}, this.reader, function(data){
                  if (data){
                    this.form.loadRecord(data.records[0])
                  }
                }, this)
              }
            JS
            :afterlayout_handler => <<-JS.l,
              function() {
                // Load initial data into the form
                if (this.initialConfig.recordData){
                  var record = this.reader.readRecord(this.initialConfig.recordData);
                  this.form.loadRecord(record);
                }
              }
            JS
            :refresh_click => <<-JS.l,
              function() {
                this.loadRecord(3)
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
            :submit => <<-JS.l,
              function() {
                this.form.submit({
                  url:this.initialConfig.interface.submit
                })
              }
            JS
          }
        end
        
      end
      
      def js_config
        res = super
        # we pass column config at the time of instantiating the JS class
        res.merge!(:fields => get_fields || config[:fields]) # first try to get columns from DB, then from config
        res.merge!(:data_class_name => config[:data_class_name])
        res.merge!(:record_data => config[:record].to_array(get_fields))
        res
      end

    end
  end
end