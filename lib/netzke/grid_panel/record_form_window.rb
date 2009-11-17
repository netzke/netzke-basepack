module Netzke::GridPanelExtras
  class RecordFormWindow < Window
    def actions
      {:ok => {:text => "OK"}, :cancel => {:text => "Cancel"}}
    end
    
    def initial_config
      super.deep_merge({
        :ext_config => {
          :modal => true,
          :width => "60%",
          :height => "90%",
          :fbar => [:ok, :cancel]
        }
      })
    end
    
    def self.js_extend_properties
      {
        :button_align => "right",
        
        :init_component => <<-END_OF_JAVASCRIPT.l,
          function(){
            #{js_full_class_name}.superclass.initComponent.call(this);
            this.getWidget().on("submitsuccess", function(){this.closeRes = "ok"; this.close();}, this);
          }
        END_OF_JAVASCRIPT
        
        :on_ok => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.getWidget().onApply();
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