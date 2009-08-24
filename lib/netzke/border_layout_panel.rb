module Netzke
  class BorderLayoutPanel < Base
    api :resize_region
    
    REGIONS = %w(center west east south north).map(&:to_sym)

    #
    # JS-class generation
    #
    module ClassMethods
      # def js_listeners
      #   {
      #     :afterlayout => {:fn => "this.setResizeEvents".l, :scope => this}
      #   }
      # end

      # def js_before_constructor
      #   <<-END_OF_JAVASCRIPT.l
      #   END_OF_JAVASCRIPT
      # end

      # def js_common_config_for_constructor
      #   super.merge({
      #     :items => "items".l
      #   })
      # end

      def js_extend_properties
        {
          :layout => 'border',
          
          :init_component => <<-END_OF_JAVASCRIPT.l,
            function(){
              this.items = [];
              Ext.each(['center', 'west', 'east', 'south', 'north'], function(r){
                var configName = r+'Config';
                if (this[configName]){
                  var regionConfig = this.regions[r] || {};
                  regionConfig.layout = 'fit';
                  regionConfig.region = r;
                  regionConfig.items = [new Ext.netzke.cache[this[configName].widgetClassName](this[configName])]
                  this.items.push(regionConfig);

                  // A function to access a region widget (even if the widget gets reloaded, the function will work).
                  // E.g.: getEastWidget()
                  this['get'+r.capitalize()+'Widget'] = function(){
                    return this.find('region', r)[0].getWidget()
                  }.createDelegate(this)
                };
              }, this);
              
              // Now let Ext.Panel do the rest
              Ext.netzke.cache.BorderLayoutPanel.superclass.initComponent.call(this);
              
              // Set events
              this.on('afterlayout', this.setResizeEvents, this);
            }
          END_OF_JAVASCRIPT
          
          :get_region_widget => <<-END_OF_JAVASCRIPT.l,
            function(region){
              return this.find('region', region)[0].getWidget()
            }
          END_OF_JAVASCRIPT
          
          :set_resize_events => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.items.each(function(item, index, length){
              if (!item.oldSize) item.oldSize = item.getSize();
              if (item.region == 'east' || item.region == 'west') item.on('resize', function(panel, w, h){
                if (panel.oldSize.width != w) {
                  this.resizeRegion({region_name: panel.region, new_width:w});
                  panel.oldSize.width = w;
                }
                return true;
              }, this);
              else if (item.region == 'south' || item.region == 'north') item.on('resize', function(panel, w, h){
                if (panel.oldSize.height != h) {
                  this.resizeRegion({region_name: panel.region, new_height:h});
                  panel.oldSize.height = h;
                }
                return true;
              }, this);
            }, this);
            this.un('afterlayout', this.setResizeEvents, this); // to avoid redefinition of resize events
          }
        END_OF_JAVASCRIPT
      }
      end
    end
    extend ClassMethods

    def initial_aggregatees
      config[:regions] || {}
    end
    
    def region_aggregatees
      aggregatees.reject{ |k,v| !REGIONS.include?(k) }
    end
    
    def js_config
      regions = {}
      REGIONS.each do |r|
        if region_aggr = aggregatees[r]
          regions.merge!(r => region_aggr[:region_config] || {})
        end
      end
      super.merge(:regions => regions)
    end
  
    def resize_region(params)
      persistent_config["regions__#{params["region_name"]}__region_config__width"] = params["new_width"].to_i if params["new_width"]
      persistent_config["regions__#{params["region_name"]}__region_config__height"] = params["new_height"].to_i if params["new_height"]
      {}
    end
    
  end
end