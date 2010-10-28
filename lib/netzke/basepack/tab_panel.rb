module Netzke
  module Basepack
    # = TabPanel
    # 
    # Features:
    # * Dynamically loads components for the tabs that get activated for the first time
    # * Is loaded along with the active component - saves a request to the server
    # * (TODO) Provides the method markTabsOutdated to mark all inactive tabs as 'outdated', and calls "update" method on components in tabs when they get activated
    # * (TODO) Stores the last active tab in persistent_config
    # 
    # ToDo:
    # * Introduce a second or two delay before informing the server about a tab switched
    class TabPanel < Netzke::Base
      
      include WrapLazyLoaded
      
      js_base_class "Ext.TabPanel"
      
      js_method :init_component, <<-JS
        function(params){
          #{js_full_class_name}.superclass.initComponent.call(this);
          this.on('tabchange', function(self, i){
            if (i && i.wrappedComponent && !i.items.first()) {
              this.loadComponent({name: i.wrappedComponent, container: i.id});
            }
          }, this);
        }
      JS
      
    end
  end
end