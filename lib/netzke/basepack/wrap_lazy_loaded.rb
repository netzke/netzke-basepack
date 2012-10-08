module Netzke
  module Basepack
    # Include this module into your component component class when you want lazy-loaded component in config to be auto-replaced with
    # a panel with the 'fit' layout, and a property wrappedComponent set to the name of the original component.
    # Used, for instance, in TabPanel and AccordionPanel to dynamically load components on expanding a panel or clicking
    # a tab.
    module WrapLazyLoaded
      def extend_item(item)
        item = super

        # when a nested component with lazy loading is detected, it gets replaced with a 'fit' panel,
        # into which later the component itself is dynamically loaded on request.
        merged_config = components[item[:netzke_component]].try(:merge, item)
        if merged_config && !merged_config[:eager_loading]
          {
            layout: :fit,
            wrapped_component: merged_config[:item_id],
            title: merged_config[:title] || merged_config[:item_id].humanize,
            icon_cls: merged_config[:icon_cls],
            disabled: merged_config[:disabled]
          }
        else
          item
        end
      end
    end
  end
end
