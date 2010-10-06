module Netzke
  module Basepack
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
    class Wrapper < Netzke::Base
      js_properties(
        :layout => 'fit',
        
        # invisible
        :header => false,
        :border => false,
      )
    end
  end
end