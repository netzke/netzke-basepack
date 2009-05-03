module Netzke
  #
  # TabPanel
  # 
  # Features:
  # * Dynamically loads widgets for the tabs that get activated for the first time
  # * Is loaded along with the active widget - saves a request to the server
  #
  # TODO:
  # * Stores the last active tab in persistent_config
  # 
  class TabPanel < Base
    def self.js_base_class
      "Ext.TabPanel"
    end

    def self.js_extend_properties
      {
        # loads widget into the panel if it wasn't loaded yet
        :load_item_widget => <<-JS.l
          function(panel) {
            if (!panel.getWidget()) {
              if (panel.id === this.id+"_active"){
                // active widget only needs to be instantiated, as its class has been loaded already
                var activeItemConfig = this.initialConfig[panel.widget+"Config"];
                panel.add(new Ext.netzke.cache[activeItemConfig.widgetClassName](activeItemConfig));
                panel.doLayout(); // always needed after adding a component
              } else {
                // load the widget from the server
                panel.loadWidget(this.id + "__" + panel.widget + "__get_widget");
              }
            }
          }
        JS
      }
    end
    
    def items
      @items ||= config[:items]
    end

    def js_config
      active_item_config = items.detect{|i| i[:active]}
      super.merge({
        :items => fit_panels,
        :active_tab => active_item_config && id_name + '_active'
      })
    end

    # some configuration normalization
    def initialize(*args)
      super
      
      # to remove duplicated active panels
      seen_active = false

      items.each_with_index do |item, i|
        # if the item is provided without a name, give it a generated name
        item[:name] ||= "item#{i}"

        # remove duplicated "active" configuration
        if item[:active]
          item[:active] = nil if seen_active
          seen_active = true
        end
      end
    end
    
    # the items are late aggregatees, besides the one that is configured active
    def initial_aggregatees
      res = {}
      items.each_with_index do |item, i|
        item[:late_aggregation] = !item[:active]
        res.merge!(item[:name].to_sym => item)
      end
      res
    end

    def self.js_default_config
      super.merge({
        :id_delimiter => "___", # the default is "__", which conflicts with Netzke
        :defaults => {:layout => 'fit'}, # all tabs will be Ext.Panel-s with layout 'fit' ("fit-panels")
        :listeners => {
          # when tab is activated, its content gets loaded from the server
          :tabchange => {
            :fn => <<-JS.l
              function(self, tab){
                this.loadItemWidget(tab);
              }
            JS
          }
        }
      })
    end
    
    def fit_panels
      res = []
      items.each_with_index do |item, i|
        item_config = {
          :id => item[:active] && id_name + '_active',
          :title => item[:title] || (item[:name] && item[:name].humanize),
          :widget => item[:name] # to know which fit-panel will load which widget
        }
        res << item_config
      end
      res
    end
    
  end
end