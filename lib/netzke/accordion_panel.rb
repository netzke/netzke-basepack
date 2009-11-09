module Netzke
  # == AccordionPanel
  # 
  # == Features:
  # * Dynamically loads widgets for the panels that get expanded for the first time
  # * Is loaded along with the active widget - saves a request to the server
  #
  # Future features:
  # * Stores the last active panel in persistent_config
  class AccordionPanel < Base
    
    # JavaScript part
    def self.js_extend_properties
      {
        :layout => 'accordion',
        :defaults => {:layout => 'fit'},
        :init_component => <<-END_OF_JAVASCRIPT.l,
          function(){
            #{js_full_class_name}.superclass.initComponent.call(this);

            // Set events
            this.items.each(function(i){
              // Set the expand event
              i.on('expand', this.loadItemWidget, this);
              
              // If not collapsed, add the active aggregatee (item) into it
              if (!i.collapsed) {
                var preloadedItemConfig = this[i.widget.camelize(true) + "Config"];
                var klass = this.classifyScopedName(preloadedItemConfig.scopedClassName);
                i.add(new klass(preloadedItemConfig));
                i.doLayout(); // always needed after adding a component
              }
            }, this);
          }
        END_OF_JAVASCRIPT
        
        # Loads widget into the panel if it wasn't loaded yet
        :load_item_widget => <<-END_OF_JAVASCRIPT.l,
          function(panel) {
            // if (!panel.getWidget()) panel.loadWidget(this.id + "__" + panel.widget + "__get_widget");
            var preloadedItemConfig = this[panel.widget.camelize(true) + "Config"];
            
            if (preloadedItemConfig){
              // preloaded widget only needs to be instantiated, as its class and configuration have already been loaded
              var klass = this.classifyScopedName(preloadedItemConfig.scopedClassName);
              panel.add(new klass(preloadedItemConfig));
              panel.doLayout(); // always needed after adding a component
            } else {
              // load the widget from the server
              this.loadAggregatee({id:panel.widget, container:panel.id});
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

    # "Fit-panels" - panels of layout 'fit' (effectively the accordion panels) that will contain the widgets ("items")
    def fit_panels
      res = []
      config[:items].each_with_index do |item, i|
        res << {
          # :id => item[:active] && global_id + '_active', # to mark the fit-panel which will contain the active widget
          :title => item[:title] || (item[:name] && item[:name].to_s.humanize),
          :widget => item[:name], # to know which fit panel will load which widget
          :collapsed => !(item[:active] || false)
        }
      end
      res
    end

    # All items become *late* aggregatees, besides the ones that are marked "active"
    def initial_aggregatees
      res = {}
      config[:items].each_with_index do |item, i|
        item[:late_aggregation] = !item[:active]
        res.merge!(item[:name].to_sym => item)
      end
      res
    end

    
  end
end