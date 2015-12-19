module Netzke
  module Basepack
    # A tab panel that can load components dynamically by their class name. Components can be loaded in the current or new tab.
    # For example:
    #
    #     this.netzkeLoadComponentByClass('BookGrid', {newTab: true, serverConfig: {read_only: true}});
    #
    class DynamicTabPanel < Netzke::Base
      client_class do |c|
        c.extend = "Ext.tab.Panel"
      end

      # Override this method if you need more control on what components can/cannot be loaded, or in order to access
      # `client_config`
      component :child do |c|
        c.class_name = c.client_config[:class_name] || "Netzke::Core::Panel"
      end
    end
  end
end
