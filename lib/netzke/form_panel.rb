module Netzke
  class FormPanel < Base
    interface :submit, :load
    
    class << self
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
      
      
    end
    
    def self.js_extend_properties
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

    # default configuration
    def initial_config
      {
        :ext_config => {
          :config_tool => false, 
          :border => true
        },
        :layout_manager => "NetzkeLayout",
        :field_manager => "NetzkeFormPanelField"
      }
    end

    def tools
      [{:id => 'refresh', :on => {:click => 'refreshClick'}}]
    end
    
    def actions
      [{
        :text => 'Previous', :handler => 'previous'
      },{
        :text => 'Next', :handler => 'next'
      },{
        :text => 'Apply', :handler => 'submit', :disabled => !@permissions[:update] && !@permissions[:create]
      }]
    end
    
    def js_config
      res = super
      # we pass column config at the time of instantiating the JS class
      res.merge!(:fields => get_fields || config[:fields]) # first try to get columns from DB, then from config
      res.merge!(:data_class_name => config[:data_class_name])
      res.merge!(:record_data => config[:record].to_array(get_fields))
      res
    end
    
    # get fields from layout manager
    def get_fields
      @fields ||=
      if layout_manager_class && field_manager_class
        layout = layout_manager_class.by_widget(id_name)
        layout ||= field_manager_class.create_layout_for_widget(self)
        layout.items_hash  # TODO: bad name!
      else
        Netzke::Column.default_columns_for_widget(self)
      end
    end
    
    def submit(params)
      params.delete(:authenticity_token)
      params.delete(:controller)
      params.delete(:action)
      book = Book.find(params[:id])
      if book.nil?
        book = Book.create(params)
      else
        book.update_attributes(params)
      end
    rescue ActiveRecord::UnknownAttributeError # unknown attributes get ignored
      book.save
      [book.to_array(get_fields)].to_json
    end
    
    def load(params)
      logger.debug { "!!! params: #{params.inspect}" }
      klass = config[:data_class_name].constantize
      case params[:neighbour]
      when "previous" then book = klass.previous(params[:id])
      when "next"     then book = klass.next(params[:id])
      else                 book = klass.find(params[:id])
      end
      [book && book.to_array(get_fields)].to_json
    end
    
    protected
    
    def layout_manager_class
      config[:layout_manager].constantize
    rescue NameError
      nil
    end
    
    def field_manager_class
      config[:field_manager].constantize
    rescue NameError
      nil
    end
    
    def available_permissions
      %w(read update create delete)
    end
    
      
  end
end