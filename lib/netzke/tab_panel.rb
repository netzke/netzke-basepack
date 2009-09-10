module Netzke
  # TabPanel
  # 
  # Features:
  # * Dynamically loads widgets for the tabs that get activated for the first time
  # * Is loaded along with the active widget - saves a request to the server
  # * Provides the method markTabsOutdated to mark all inactive tabs as 'outdated', and calls "update" method on widgets in tabs when they get activated
  #
  # TODO:
  # * Stores the last active tab in persistent_config
  # * Introduce a second or two delay before informing the server about a tab switched
  # 
  class TabPanel < Base
    api :api_activate_tab
    
    def self.js_base_class
      "Ext.TabPanel"
    end

    def self.js_extend_properties
      {
        :id_delimiter => "___", # the default was "__", which conflicts with Netzke's double underscore notation
        :defaults => {:layout => 'fit'}, # all tabs will be Ext.Panel-s with layout 'fit' ("fit-panels")
        
        :render => <<-END_OF_JAVASCRIPT.l,
          function(el){
            Ext.netzke.cache.#{short_widget_class_name}.superclass.render.call(this, el);
            
            // We do this all in +render+ because only at this moment the activeTab is actually activated
            var activeTab = this.getActiveTab();
            this.loadWidgetInto(activeTab);
            this.on('tabchange', this.onTabChange, this);
          }
        END_OF_JAVASCRIPT
        
        :load_widget_into => <<-END_OF_JAVASCRIPT.l,
          function(fitPanel){
            var preloadedItemConfig = this[fitPanel.widget.camelize(true)+"Config"];
            if (preloadedItemConfig){
              // preloaded widget only needs to be instantiated, as its class and configuration have already been loaded
              fitPanel.add(new Ext.netzke.cache[preloadedItemConfig.widgetClassName](preloadedItemConfig));
              fitPanel.doLayout();
            } else {
              // load the widget from the server
              this.loadAggregatee({id:fitPanel.widget, container:fitPanel.id});
            }
          }
        END_OF_JAVASCRIPT
        
        :mark_tabs_outdated => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.items.each(function(i){
              if (this.getActiveTab() != i){
                i.outdated = true
              }
            }, this);
          }
        END_OF_JAVASCRIPT
        
        # bulkExecute in active tab
        :execute_in_active_tab => <<-END_OF_JAVASCRIPT.l,
          function(commands){
            this.getActiveTab().getWidget().bulkExecute(commands);
          }
        END_OF_JAVASCRIPT
        
        :get_loaded_children => <<-END_OF_JAVASCRIPT.l,
          function(){
            var res = [];
            this.items.each(function(tab){
              var kid = tab.getWidget();
              if (kid) { res.push(kid) }
            }, this);
            return res;
          }
        END_OF_JAVASCRIPT
        
        :on_tab_change => <<-END_OF_JAVASCRIPT.l
          function(self, tab) {
            // load widget into the panel if it wasn't loaded yet
            if (!tab.getWidget()) {
              this.loadWidgetInto(tab);
            }
            
            // inform the server about active tab change
            this.apiActivateTab({tab:tab.widget});
            
            // call "update" on the widget
            if (tab.outdated) {
              tab.outdated = false;
              var widget = tab.getWidget();
              if (widget && widget.update) {widget.update.call(widget)};
            }
          }
        END_OF_JAVASCRIPT
      }
    end
    
    def items
      @items ||= config[:items]
    end

    def js_config
      super.merge({
        :items => fit_panels,
        :active_tab => id_name + '_active' # id of the fit panel that is active
      })
    end

    # some configuration normalization
    def initialize(*args)
      super
      
      # to remove duplicated active tabs
      first_active = nil

      items.each_with_index do |item, i|
        # if the item is provided without a name, give it a generated name
        item[:name] ||= "item#{i}"

        # remove duplicated "active" configuration
        if item[:active]
          if first_active.nil?
            first_active = item.name
          else
            item[:active] = nil
          end
        end
      end
      
      # the first tab is forced to become active, if none was configured as active
      items.first[:active] = true and first_active = items.first.name if first_active.nil?
      
      widget_session[:active_tab] = first_active
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

    # "Fit panels" - Panels with layout 'fit' that serve as containers for (dynamically) loaded widgets
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