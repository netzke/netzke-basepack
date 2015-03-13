module Netzke
  module Basepack
    # A tab panel that can load components dynamically by their class name. Components can be loaded in the current or new tab.
    # For example:
    #
    #     this.netzkeLoadComponentByClass('BookGrid', {newTab: true, clientConfig: {read_only: true}});
    #
    class DynamicTabPanel < Netzke::Base
      js_configure do |c|
        c.extend = "Ext.tab.Panel"
        c.mixin
      end

      # Override this method if you need more control on what components can/cannot be loaded, or in order to access
      # `client_config`
      component :child do |c|
        # c.client_config <== is accessible here
        c.klass = (c.client_config[:klass] || "Netzke::Core::Panel").constantize
      end
    end
  end
end
