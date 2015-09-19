module Netzke
  module Basepack
    # Include this module into your component component class when you want lazy-loaded component in config to be auto-replaced with
    # a panel with the 'fit' layout, and a property wrappedComponent set to the name of the original component.
    # Used, for instance, in TabPanel and Accordion to dynamically load components on expanding a panel or clicking
    # a tab.
    module WrapLazyLoaded
      def js_configure(cfg)
        super
        cfg.items = cfg.items.each_with_index.map do |item,i|
          c = component_config(item[:netzke_component]).try(:merge, item)

          # when a nested component with lazy loading is detected, it gets replaced with a 'fit' panel,
          # into which later the component itself is dynamically loaded on request.
          if c && !c[:eager_loading] && i != config.active_tab.to_i # so it works for both TabPanel and Accordion
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
end
