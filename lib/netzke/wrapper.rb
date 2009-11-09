module Netzke
  # = Wrapper
  # 
  # Simple Ext.Panel with layout 'fit' that wraps up another Netzke widget. Can be useful in HTML pages where
  # a widget should be dynamically configured, to not reload the entire page after configuration (Wrapper 
  # will reload the widget automatically).
  # 
  # == Configuration
  # * <tt>:item</tt> - configuration hash for wrapped widget
  # 
  # Example:
  # 
  #   netzke :wrapper, :item => {
  #     :widget_class_name => "FormPanel",
  #     :data_class_name => "User"
  #   }
  class Wrapper < Base
    def self.js_extend_properties
      super.merge({
        :layout => 'fit',
        
        # invisible
        :header => false,
        :border => false,
        
        :init_component => <<-END_OF_JAVASCRIPT.l,
          function(){
            #{js_full_class_name}.superclass.initComponent.call(this);

            // instantiate the item
            this.instantiateChild(this.itemConfig);
          }
        END_OF_JAVASCRIPT
      })
    end

    def initial_aggregatees
      {:item => config[:item]}
    end
    
  end
end