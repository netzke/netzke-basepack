module Netzke
  #
  # AccordionPanel
  # 
  # Features:
  # * Dynamically loads widgets for the panels that get expanded for the first time
  # * Is loaded along with the active widget - saves a request to the server
  #
  # TODO:
  # * Stores the last active panel in persistent_config
  # 
  class AccordionPanel < Base
    #
    # JS-class generation
    #
    module ClassMethods

      def js_common_config_for_constructor
        super.merge({
          :layout => 'accordion',
          :defaults => {:layout => 'fit'}, # Container's items will be of type Panel with layout 'fit' ("fit-panels")
          :listeners => {
            # every item gets an expand event set, which dynamically loads a widget into this item 
            :add => {
              :fn => <<-END_OF_JAVASCRIPT.l
              function(self, comp){
                comp.on('expand', this.loadItemWidget, self)
              }
              END_OF_JAVASCRIPT
            }
          }
        })
      end

      def js_extend_properties
        {
          # loads widget into the panel if it wasn't loaded yet
          :load_item_widget => <<-END_OF_JAVASCRIPT.l,
            function(panel) {
              if (!panel.getWidget()) panel.loadWidget(this.id + "__" + panel.widget + "__get_widget");
            }
          END_OF_JAVASCRIPT
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
      expanded_widget_config = config[:items].detect{|i| i[:active]}
      super.merge({
        :items => fit_panels,
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

    # fit-panels - panels of layout 'fit' that will contain the widgets (items)
    def fit_panels
      res = []
      config[:items].each_with_index do |item, i|
        res << {
          :id => item[:active] && id_name + '_active', # to mark the fit-panel which will contain the active widget
          :title => item[:title] || (item[:name] && item[:name].humanize),
          :widget => item[:name], # to know which fit panel will load which widget
          :collapsed => !(item[:active] || false)
        }
      end
      res
    end
    
  end
end