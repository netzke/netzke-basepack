module Netzke
  class FormPanel < Base
    include_extras
    interface :submit, :load
    
    # default configuration
    def initial_config
      {
        :ext_config => {
          :config_tool => true, 
          :border => true
        },
        :layout_manager => "NetzkeLayout",
        # :field_manager => "NetzkeFormPanelField"
        :field_manager => false
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
    
    # get fields from layout manager
    def get_fields
      @fields ||=
      if layout_manager_class && field_manager_class
        layout = layout_manager_class.by_widget(id_name)
        layout ||= field_manager_class.create_layout_for_widget(self)
        layout.items_hash  # TODO: bad name!
      else
        Netzke::Column.default_fields_for_widget(self)
      end
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