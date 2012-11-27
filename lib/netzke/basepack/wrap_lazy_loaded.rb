module Netzke
  module Basepack
    # Include this module into your component component class when you want lazy-loaded component in config to be auto-replaced with
    # a panel with the 'fit' layout, and a property wrappedComponent set to the name of the original component.
    # Used, for instance, in TabPanel and Accordion to dynamically load components on expanding a panel or clicking
    # a tab.
    module WrapLazyLoaded
      def extend_item(item)
        item = super

        c = components[item[:netzke_component]].try(:merge, item)

        # when a nested component with lazy loading is detected, it gets replaced with a 'fit' panel,
        # into which later the component itself is dynamically loaded on request.
        if c && !c[:eager_loading]
          { layout: :fit,
            wrapped_component: c[:item_id],
            title: c[:title] || c[:item_id].humanize,
            icon_cls: c[:icon_cls],
            disabled: c[:disabled]
          }
        else
          item
        end
      end
    end
  end
end
