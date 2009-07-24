module Netzke
  #
  # TabPanel
  # 
  # Features:
  # * Dynamically loads widgets for the tabs that get activated for the first time
  # * Is loaded along with the active widget - saves a request to the server
  # 
  # * Provides the method markTabsOutdated to mark all inactive tabs as 'outdated', and calls "update" method on
  # widgets in tabs when they get activated
  #
  # TODO:
  # * Stores the last active tab in persistent_config
  # 
  class TabPanel < Base
    api :api_activate_tab
    
    def self.js_base_class
      "Ext.TabPanel"
    end

    def self.js_extend_properties
      {
        
        :mark_tabs_outdated => <<-JS.l,
          function(){
            this.items.each(function(i){
              if (this.getActiveTab() != i){
                i.outdated = true
              }
            }, this);
          }
        JS
        
        # bulkExecute in active tab
        :execute_in_active_tab => <<-JS.l,
          function(commands){
            this.getActiveTab().getWidget().bulkExecute(commands);
          }
        JS
        
        :get_loaded_children => <<-JS.l,
          function(){
            var res = [];
            this.items.each(function(tab){
              var kid = tab.getWidget();
              if (kid) { res.push(kid) }
            }, this);
            return res;
          }
        JS
        
        # loads widget into the panel if it wasn't loaded yet
        :load_item_widget => <<-JS.l
          function(panel) {
            if (!panel.getWidget()) {
              if (preloadedItemConfig = this.initialConfig[panel.widget+"Config"]){
                // preloaded widget only needs to be instantiated, as its class and configuration have already been loaded
                panel.add(new Ext.netzke.cache[preloadedItemConfig.widgetClassName](preloadedItemConfig));
                panel.doLayout(); // always needed after adding a component
              } else {
                // load the widget from the server
                this.loadAggregatee({id:panel.widget, container:panel.id});
              }
            }
            
            // inform the server about active tab changed
            this.apiActivateTab({tab:panel.widget});
            
            // call "update" on the widget
            if (panel.outdated) {
              delete panel.outdated;
              var widget = panel.getWidget();
              if (widget && widget.update) {widget.update.call(widget)};
            }
          }
        JS
      }
    end
    
    def items
      @items ||= config[:items]
    end

    def js_config
      super.merge({
        :items => fit_panels,
        :active_tab => id_name + '_active'
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
      
      # the first tab is forced to become active, if none was configured as active
      items.first[:active] = true unless seen_active
    end
    
    # the items are late aggregatees, besides the one that is configured active
    def initial_aggregatees
      res = {}
      items.each_with_index do |item, i|
        item[:late_aggregation] = !item[:active] && !item[:preloaded]
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
    
    def api_activate_tab(params)
      widget_session[:active_tab] = params[:tab]
      {}
    end
    
    def get_active_tab
      aggregatee_instance(widget_session[:active_tab])
    end
  end
end