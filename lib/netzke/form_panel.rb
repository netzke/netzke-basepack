module Netzke
  class FormPanel < Base
    include_extras(__FILE__)
    interface :submit, :load

    include Netzke::DbFields
    
    def self.widget_type
      :form
    end
    
    # default configuration
    def initial_config
      {
        :ext_config => {
          :config_tool => true
        },
        :layout_manager => "NetzkeLayout",
        :field_manager => "NetzkeFormPanelField",

        :persistent_layout => false,
        :persistent_config => true
      }
    end

    def tools
      [{:id => 'refresh', :on => {:click => 'refreshClick'}}]
    end
    
    def actions
      [{
      #   :text => 'Previous', :handler => 'previous'
      # },{
      #   :text => 'Next', :handler => 'next'
      # },{
        :text => 'Apply', :handler => 'submit', :disabled => !@permissions[:update] && !@permissions[:create]
      }]
    end
    
    # get fields from layout manager
    def get_fields
      @fields ||=
      if config[:persistent_layout] && layout_manager_class && field_manager_class
        layout = layout_manager_class.by_widget(id_name)
        layout ||= field_manager_class.create_layout_for_widget(self)
        layout.items_hash  # TODO: bad name!
      else
        default_db_fields
      end
    end

    # parameters used to instantiate the JS object
    def js_config
      res = super
      # we pass column config at the time of instantiating the JS class
      res.merge!(:fields => get_fields || config[:fields]) # first try to get columns from DB, then from config
      res.merge!(:data_class_name => config[:data_class_name])
      res.merge!(:record_data => config[:record].to_array(get_fields)) if config[:record]
      res
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