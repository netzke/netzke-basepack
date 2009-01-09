module Netzke
  class BorderLayoutPanel < Base
    interface :resize_region
    
    REGIONS = %w(center west east south north).map(&:to_sym)

    #
    # JS-class generation
    #
    class << self
      def js_listeners
        {
          :afterlayout => {:fn => "this.setResizeEvents".l, :scope => this}
        }
      end

      def js_before_constructor
        <<-JS.l
          var items = [];
          Ext.each(['center', 'west', 'east', 'south', 'north'], function(r){
            var configName = r+'Config';
            if (config[configName]){
              var regionConfig = config.regions[r] || {};
              regionConfig.layout = 'fit';
              regionConfig.region = r;
              regionConfig.items = [new Ext.componentCache[config[configName].widgetClassName](config[configName])]
              items.push(regionConfig);
            };
          }, this)
        JS
      end

      def js_default_config
        super.merge({
          :layout => 'border',
          :items => "items".l
        })
      end

      def js_extend_properties
        {:set_resize_events => <<-JS.l,
          function(){
            this.items.each(function(item, index, length){
              if (!item.oldSize) item.oldSize = item.getSize();
              if (item.region == 'east' || item.region == 'west') item.on('resize', function(panel, w, h){
                if (panel.oldSize.width != w) {
                  Ext.Ajax.request({
                    url:this.initialConfig.interface.resizeRegion,
                    params: {region_name: panel.region, new_width:w}
                  });
                  panel.oldSize.width = w;
                }
            		return true;
              }, this);
              else if (item.region == 'south' || item.region == 'north') item.on('resize', function(panel, w, h){
                if (panel.oldSize.height != h) {
                  Ext.Ajax.request({
                    url:this.initialConfig.interface.resizeRegion,
                    params: {region_name: panel.region, new_height:h}
                  });
                  panel.oldSize.height = h;
                }
            		return true;
              }, this);
            }, this);
            this.un('afterlayout', this.setResizeEvents, this); // to avoid redefinition of resize events
          }
        JS
      }
      end
      
    end
    
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
          height = @pref["#{r}_height"] ||= regions[r][:height] if regions[r][:height]
          width = @pref["#{r}_width"] ||= regions[r][:width] if regions[r][:width]
          regions[r].merge!(:height => height)
          regions[r].merge!(:width => width)
        end
      end
      super.merge(:regions => regions)
    end
  
    def interface_resize_region(params)
      @pref["#{params[:region_name]}_width"] = params[:new_width].to_i if params[:new_width]
      @pref["#{params[:region_name]}_height"] = params[:new_height].to_i if params[:new_height]
    end
    
    protected
  
    def extend_functions; ""; end
    def js_extra_events; ""; end
    
  end
end