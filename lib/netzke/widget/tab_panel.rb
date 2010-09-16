module Netzke::Widget
  # TabPanel
  # 
  # Features (TODO):
  # * Dynamically loads widgets for the tabs that get activated for the first time
  # * Is loaded along with the active widget - saves a request to the server
  # * Provides the method markTabsOutdated to mark all inactive tabs as 'outdated', and calls "update" method on widgets in tabs when they get activated
  #
  # TODO:
  # * Stores the last active tab in persistent_config
  # * Introduce a second or two delay before informing the server about a tab switched
  # 
  class TabPanel < Base
    include Container
    
    # api :api_activate_tab
    
    def self.js_base_class
      "Ext.TabPanel"
    end

    def self.js_properties
      {
        :active_tab => 0,
        :id_delimiter => "___", # the default was "__", which conflicts with Netzke's double underscore notation
      }
    end

    def config
      {
        :items => [{:class_name => "Widget::GridPanel", :title => "Blah1", :model => "User"}, {:title => "Blah2", :html => "Testik"}]
      }.deep_merge(super)
    end
    
  end
end