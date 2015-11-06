module Netzke
  module Basepack
    # = TabPanel
    #
    # Features:
    # * Dynamically loads components for the tabs that get activated for the first time
    # * (TODO) Provides the method markTabsOutdated to mark all inactive tabs as 'outdated', and calls "update" method on components in tabs when they get activated
    # * (TODO) Stores the last active tab in persistent config
    #
    # ToDo:
    # * Introduce a second or two delay before informing the server about a tab switched
    class TabPanel < Netzke::Base

      include WrapLazyLoaded

      client_class do |c|
        c.extend = "Ext.tab.Panel"
      end
    end
  end
end
