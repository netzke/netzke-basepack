module Netzke
  class FormPanel < Base
    # Class-level configuration with defaults
    def self.config
      set_default_config({
        :config_tool_enabled_by_default       => false,
        :persistent_layout_enabled_by_default => true,
        :persistent_config_enabled_by_default => true
      })
    end

    include Netzke::FormPanelExtras::JsBuilder
    include Netzke::FormPanelExtras::Api
    include Netzke::DbFields # database field operations
    
    # extra javascripts
    js_include %w{ xcheckbox }.map{|js| "#{File.dirname(__FILE__)}/form_panel_extras/javascripts/#{js}.js"}
    
    api :submit, :load, :get_cb_choices

    def self.widget_type
      :form
    end
    
    def initialize(*args)
      super
      @record = config[:record]
    end
    
    # default instance-level configuration
    def initial_config
      {
        :ext_config => {
          :config_tool => self.class.config[:config_tool_enabled_by_default],
        },

        :persistent_layout => self.class.config[:persistent_layout_enabled_by_default],
        :persistent_config => self.class.config[:persistent_config_enabled_by_default]
      }
    end

    def configuration_widgets
      res = []
      
      res << {
        :name              => 'fields',
        :widget_class_name => "FieldsConfigurator",
        :active            => true,
        :widget            => self
      } if config[:persistent_layout]

      res << {
        :name               => 'general',
        :widget_class_name  => "PropertyEditor",
        :widget_name        => id_name,
        :ext_config         => {:title => false}
      }
      
      res
    end

    def tools
      %w{ refresh }
    end
    
    def actions
      {
        :apply => {:text => 'Apply'}
      }
    end
    
    def bbar
      persistent_config[:bottom_bar] ||= config[:bbar] == false ? nil : config[:bbar] || %w{ apply }
    end
    
    def fields
      @fields ||= get_fields
    end

    # parameters used to instantiate the JS object
    def js_config
      res = super
      res.merge!(:fields => fields)
      res.merge!(:data_class_name => config[:data_class_name])
      res.merge!(:record_data => @record.to_array(fields)) if @record
      res
    end
 
    protected
    
    def get_fields
      if config[:persistent_layout]
        NetzkeLayoutItem.widget = id_name
        NetzkeLayoutItem.data = default_db_fields if NetzkeLayoutItem.all.empty?
        NetzkeLayoutItem.all
      else
        default_db_fields
      end.map{ |r| r.reject{ |k,v| k == :id } }
    end
      
    
    # def available_permissions
    #   %w{ read update }
    # end
    
    include ConfigurationTool # it will load aggregation with name :properties into a modal window
      
  end
end