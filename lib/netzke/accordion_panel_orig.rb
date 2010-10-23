module Netzke
  # == AccordionPanel
  # 
  # == Features:
  # * Dynamically loads components for the panels that get expanded for the first time
  # * Is loaded along with the active component - saves a request to the server
  #
  # Future features:
  # * Stores the last active panel in persistent_config
  class AccordionPanelOrig < Base
    
    # JavaScript part
    def self.js_properties
      {
        :layout => 'accordion',
        :defaults => {:layout => 'fit'},
        :init_component => <<-END_OF_JAVASCRIPT.l,
          function(){
            #{js_full_class_name}.superclass.initComponent.call(this);

            // Set events
            // this.items.each(function(i){
            //   // Set the expand event
            //   i.on('expand', this.loadItemComponent, this);
            //   
            //   // If not collapsed, add the active component (item) into it
            //   if (!i.collapsed) {
            //     var preloadedItemConfig = this[i.component.camelize(true) + "Config"];
            //     var klass = this.classifyScopedName(preloadedItemConfig.scopedClassName);
            //     i.add(new klass(preloadedItemConfig));
            //     i.doLayout(); // always needed after adding a component
            //   }
            // }, this);
          }
        END_OF_JAVASCRIPT
        
        # Loads component into the panel if it wasn't loaded yet
        :load_item_component => <<-END_OF_JAVASCRIPT.l,
          function(panel) {
            // if (!panel.getNetzkeComponent()) panel.loadComponent(this.id + "__" + panel.component + "__get_component");
            var preloadedItemConfig = this[panel.component.camelize(true) + "Config"];
            
            if (preloadedItemConfig){
              // preloaded component only needs to be instantiated, as its class and configuration have already been loaded
              var klass = this.classifyScopedName(preloadedItemConfig.scopedClassName);
              panel.add(new klass(preloadedItemConfig));
              panel.doLayout(); // always needed after adding a component
            } else {
              // load the component from the server
              this.loadComponent({id:panel.component, container:panel.id});
            }
            
          }
        END_OF_JAVASCRIPT
      }
    end

    # Some normalization of config
    def initialize(*args)
      super

      seen_active = false
      
      config[:items].each_with_index do |item, i|
        # if some items are provided without names, give them generated names
        item[:name] ||= "item#{i}"
      
        # remove duplucated :active configuration
        if item[:active]
          item[:active] = nil if seen_active
          seen_active ||= true
        end
      end
    end
    
    # Returns items configs
    def items
      @items ||= config[:items]
    end

    # Provides configs for fit panels (which will effectively be accordion panels)
    def js_config
      super.merge({
        # these "items" are not related to the "items" of the config, rather these are the items required by the the accordion panel
        :items => fit_panels
      })
    end

    # "Fit-panels" - panels of layout 'fit' (effectively the accordion panels) that will contain the components ("items")
    def fit_panels
      res = []
      config[:items].each_with_index do |item, i|
        res << {
          # :id => item[:active] && global_id + '_active', # to mark the fit-panel which will contain the active component
          :title => item[:title] || (item[:name] && item[:name].to_s.humanize),
          :component => item[:name], # to know which fit panel will load which component
          :collapsed => !(item[:active] || false)
        }
      end
      res
    end

    # All items become *late* components, besides the ones that are marked "active"
    def initial_components
      res = {}
      config[:items].each_with_index do |item, i|
        item[:lazy_loading] = !item[:active] && !item[:preloaded]
        res.merge!(item[:name].to_sym => item)
      end
      res
    end

    
  end
end