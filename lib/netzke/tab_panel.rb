module Netzke
  class TabPanel < Base
    def self.js_base_class
      "Ext.TabPanel"
    end

    def self.js_extend_properties
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
    
    def js_config
      active_item_config = config[:items].select{|i| i[:active]}.first
      super.merge({
        :active_item => active_item_config && active_item_config[:name],
        :items => items
      })
    end

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
    
    # the items are late aggregatees, besides the ones that are marked "active"
    def initial_aggregatees
      res = {}
      config[:items].each_with_index do |item, i|
        item[:late_aggregation] = !item[:active]
        res.merge!(item[:name].to_sym => item)
      end
      res
    end
    

    def self.js_default_config
      super.merge({
        :active_tab => 0,
        :id_delimiter => "___", # otherwise it conflicts with Netzke
        :defaults => {:layout => 'fit'}, # all items will be of type Panel with layout 'fit'
        :listeners => {
          # every item gets an expand event set, which dynamically loads a widget into this item 
          :tabchange => {
            :fn => <<-JS.l
            function(self, tab){
              this.loadItemWidget(tab);
              // comp.on('expand', this.loadItemWidget, self)
            }
            JS
          }
        }
      })
    end
    
    def items
      res = []
      config[:items].each_with_index do |item, i|
        item_config = {
          # :id => item[:active] && id_name + '_active',
          :title => item[:title] || (item[:name] && item[:name].humanize),
          :container_for => item[:name] # to know which fit panel will load which widget
        }
        res << item_config
      end
      res
    end
    
  end
end