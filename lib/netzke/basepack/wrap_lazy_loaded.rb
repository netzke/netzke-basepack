module Netzke
  module Basepack
    # Include this module into your component component class when you want lazy-loaded component in config to be auto-replaced with
    # a panel with the 'fit' layout, and a property wrappedComponent set to the name of the original component.
    # Used, for instance, in TabPanel and AccordionPanel to dynamically load components on expanding a panel or clicking
    # a tab.
    module WrapLazyLoaded
      def items
        orig = super.dup
        orig.each do |item|
          wrapped_component = components[item[:component]]
          # When a nested component with lazy loading is detected, it gets replaced with a 'fit' panel,
          # into which later the component itself is dynamically loaded on request.
          if wrapped_component && wrapped_component[:lazy_loading]
            item.replace({
              :layout => 'fit',
              :wrapped_component => wrapped_component[:name],
              :title => wrapped_component[:title] || wrapped_component[:name],
              :icon_cls => wrapped_component[:icon_cls],
              :disabled => wrapped_component[:disabled]
            })
          end
        end
        orig
      end
    end
  end
end