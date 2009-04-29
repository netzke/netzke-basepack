module Netzke
  class FormPanel < Base
    # Class-level configuration with defaults
    def self.config
      set_default_config({
        :field_manager => "NetzkeFormPanelField",
      })
    end

    include Netzke::FormPanelExtras::JsBuilder
    include Netzke::FormPanelExtras::Interface
    include Netzke::DbFields # database field operations
    
    # extra javascripts
    js_include %w{ xcheckbox xdatetime }.map{|js| "#{File.dirname(__FILE__)}/form_panel_extras/javascripts/#{js}.js"}
    
    interface :submit, :load

    def self.widget_type
      :form
    end
    
    # default instance-level configuration
    def initial_config
      {
        :ext_config => {
          :config_tool => true
        },

        :persistent_layout => true,
        :persistent_config => true
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
    
    def get_fields
      if config[:persistent_layout]
        NetzkeLayoutItem.widget = id_name
        NetzkeLayoutItem.data = default_db_fields if NetzkeLayoutItem.all.empty?
        NetzkeLayoutItem.all
      else
        default_db_fields
      end
    end
      
    # def get_fields_old
    #   @fields ||=
    #   if config[:persistent_layout] && layout_manager_class && field_manager_class
    #     layout = layout_manager_class.by_widget(id_name)
    #     layout ||= field_manager_class.create_layout_for_widget(self)
    #     layout.items_arry_without_hidden
    #   else
    #     default_db_fields
    #   end
    # end

    # parameters used to instantiate the JS object
    def js_config
      res = super
      # we pass column config at the time of instantiating the JS class
      res.merge!(:fields => get_fields) # first try to get columns from DB, then from config
      res.merge!(:data_class_name => config[:data_class_name])
      res.merge!(:record_data => config[:record].to_array(get_fields)) if config[:record]
      res
    end
 
    protected
    
    def field_manager_class
      self.class.config[:field_manager].constantize
    rescue NameError
      nil
    end
    
    # def available_permissions
    #   %w{ read update }
    # end
    
    include ConfigurationTool # it will load aggregation with name :properties into a modal window
      
  end
end