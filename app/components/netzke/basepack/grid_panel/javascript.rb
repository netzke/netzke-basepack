module Netzke
  module Basepack
    class GridPanel < Netzke::Base
      # (Dynamic) JavaScript for GridPanel
      module Javascript
        extend ActiveSupport::Concern
      
        included do
          js_base_class "Netzke.pre.GridPanel"
          js_method :init_component, js_init_component
        end
      
        module InstanceMethods
          # The result of this method (a hash) is converted to a JSON object and passed as the configuration parameter
          # to the constructor of our JavaScript class. Override it when you want to pass any extra configuration
          # to the JavaScript side.
          def js_config
            super.merge({
              :bbar => config.has_key?(:bbar) ? config[:bbar] : default_bbar,
              :context_menu => config.has_key?(:context_menu) ? config[:context_menu] : default_context_menu,
              :columns => columns, # columns
              :model => config[:model], # the model name
              :inline_data => (get_data if config[:load_inline_data]), # inline data (loaded along with the grid panel)
              :pri => data_class.primary_key # table primary key name
            })
          end
        end

        module ClassMethods
          private
        
            # Ext.Component#initComponent, built up from pices (dependent on class-level configuration)
            def js_init_component
              # Optional "edit in form"-related events
              edit_in_form_events = <<-END_OF_JAVASCRIPT if config[:edit_in_form_available]
                if (this.enableEditInForm) {
                  this.getSelectionModel().on('selectionchange', function(selModel){
                    var disabled;
                    if (!selModel.hasSelection()) {
                      disabled = true;
                    } else {
                      // Disable "edit in form" button if new record is present in selection
                      disabled = !selModel.each(function(r){
                        if (r.isNew) { return false; }
                      });
                    };
                    this.actions.editInForm.setDisabled(disabled);
                  }, this);
                }
              END_OF_JAVASCRIPT
        
              # Result
              <<-END_OF_JAVASCRIPT
                function(){
                  // Original initComponent
                  #{js_full_class_name}.superclass.initComponent.call(this);
                  #{edit_in_form_events}
                }
          
              END_OF_JAVASCRIPT
            end
            
          # end private
        end
      
      end
    end
  end
end