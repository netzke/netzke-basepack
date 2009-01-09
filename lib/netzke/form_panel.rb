module Netzke
  class FormPanel < Base
    interface :submit
    
    class << self
      def js_base_class
        "Ext.FormPanel"
      end
      
      def js_default_config
        super.merge({
          :auto_scroll => true,
          :bbar => "config.actions".l,
          # :plugins => "plugins".l,
          :items => "fields".l,
          :default_type => 'textfield',
          :body_style => 'padding:5px 5px 0',
          :label_width => 150,

          #custom configs
          :auto_load_data => true
        })
      end
      
      def js_before_constructor
        <<-JS
        var fields = config.fields; // TODO: remove hidden fields
        JS
      end
      
    end
    
    def self.js_extend_properties
      {
        :refresh_click => <<-JS.l,
          function() {
            alert('refresh');
          }
        JS
        :previous => <<-JS.l,
          function() {
            alert('prev');
          }
        JS
        :next => <<-JS.l,
          function() {
            alert('next');
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
      # res.merge!(:record_data => config[:record].to_array)
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
      {}
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