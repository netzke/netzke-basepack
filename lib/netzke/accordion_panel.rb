module Netzke
  #
  # AccordionPanel
  # 
  # Features:
  # * Dynamically loads widgets for the panels that get expanded for the first time
  # * Gets loaded along with the widget that is to be put into the active (expanded) panel (saves us a server request)
  #
  # TODO:
  # * Stores the last active panel in the persistent_configuration
  # 
  class AccordionPanel < Base
    #
    # JS-class generation
    #
    module ClassMethods

      def js_default_config
        super.merge({
          :layout => 'accordion',
          :defaults => {:layout => 'fit'}, # all items will be of type Panel with layout 'fit'
          :listeners => {
            # every item gets an expand event set, which dynamically loads a widget into this item 
            :add => {
              :fn => <<-JS.l
              function(self, comp){
                comp.on('expand', this.loadItemWidget, self)
              }
              JS
            }
          }
        })
      end

      def js_extend_properties
        {
          # loads widget into the panel if it wasn't loaded yet
          :load_item_widget => <<-JS.l,
            function(panel) {
              if (!panel.getWidget()) panel.loadWidget(this.id + "__" + panel.containerFor + "__get_widget");
            }
          JS
          
          :on_widget_load => <<-JS.l
            function(){
              // immediately instantiate the active panel
              var activePanel = this.findById(this.id + "_active");
              var activeItemConfig = this.initialConfig[this.initialConfig.expandedItem+"Config"];
              if (activeItemConfig) activePanel.add(new Ext.netzke.cache[activeItemConfig.widgetClassName](activeItemConfig));
            }
          JS
        }
      end
    end
    extend ClassMethods
    
    # some configuration normalization
    def initialize(*args)
      super

      seen_active = false

      config[:items].each_with_index do |item, i|
        # if some items are provided without names, give them generated names
        item[:name] ||= "item#{i}"

        # remove duplucated :active configuration
        if item[:active]
          item[:active] = nil if seen_active
          seen_active = true
        end
      end
    end

    def js_config
      expanded_widget_config = config[:items].select{|i| i[:active]}.first
      super.merge({
        :items => items,
        :expanded_item => expanded_widget_config && expanded_widget_config[:name]
      })
    end

    # the items are late aggregatees, besides the ones that are marked "active"
    def initial_aggregatees
      res = {}
      config[:items].each_with_index do |item, i|
        item[:late_aggregation] = !item[:active]
        res.merge!(item[:name].to_sym => item)
      end
      res
    end

    # configuration for items (fit-panels)
    def items
      res = []
      config[:items].each_with_index do |item, i|
        item_config = {
          :id => item[:active] && id_name + '_active',
          :title => item[:title] || (item[:name] && item[:name].humanize),
          :container_for => item[:name], # to know which fit panel will load which widget
          :collapsed => !(item[:active] || false)
        }
        res << item_config
      end
      res
    end
    
  end
end