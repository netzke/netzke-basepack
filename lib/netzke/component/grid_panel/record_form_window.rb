module Netzke
  module Component
    class GridPanel < Base
      class RecordFormWindow < Window
        
        def initial_config
          super.deep_merge({
            :modal => true,
            :width => "60%",
            :height => "90%",
            :fbar => [:ok.ext_action, :cancel.ext_action]
          })
        end
    
        def self.js_properties
          {
            :button_align => "right",
        
            :init_component => <<-END_OF_JAVASCRIPT.l,
              function(){
                #{js_full_class_name}.superclass.initComponent.call(this);
                this.getNetzkeComponent().on("submitsuccess", function(){this.closeRes = "ok"; this.close();}, this);
              }
            END_OF_JAVASCRIPT
        
            :on_ok => <<-END_OF_JAVASCRIPT.l,
              function(){
                this.getNetzkeComponent().onApply();
                // this.closeRes = "ok",
                // this.close();
              }
            END_OF_JAVASCRIPT
        
            :on_cancel => <<-END_OF_JAVASCRIPT.l,
              function(){
                this.close();
              }
            END_OF_JAVASCRIPT
          }
        end
      end
    end
  end
end