module Netzke::Component
  # = Wrapper
  # 
  # Simple Ext.Panel with layout 'fit' that wraps up another Netzke component. Can be useful in HTML pages where
  # a component should be dynamically configured, to not reload the entire page after configuration (Wrapper 
  # will reload the component automatically).
  # 
  # == Configuration
  # * <tt>:item</tt> - configuration hash for wrapped component
  # 
  # Example:
  # 
  #   netzke :wrapper, :item => {
  #     :class_name => "FormPanel",
  #     :model => "User"
  #   }
  class Wrapper < Base
    def self.js_properties
      super.merge({
        :layout => 'fit',
        
        # invisible
        :header => false,
        :border => false,
      })
    end
  end
end