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
              var regionConfig = config[configName].regionConfig || {};
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
    
    # def items
    #   res = []
    #   config[:regions].each_pair do |k,v|
    #     width = v.delete(:width)
    #     height = v.delete(:height)
    #     split = v[:split].nil? ? true : v.delete(:split) # split is by default true
    #     region_config = {
    #       :region => k, 
    #       :width => @pref["#{k}_width"] || width || 100, 
    #       :height => @pref["#{k}_height"] || height || 100, 
    #       :split => split,
    #       :layout => v.delete(:layout) || 'fit',
    #       :id => @id_name + "_#{k}_region"
    #     }
    #     region_widget_instance = "Netzke::#{v[:widget_class_name]}".constantize.new(v.merge(:name => "#{id_name}__#{k}"))
    #     region_config.merge!(v)
    #     region_config[:items] = ["new Ext.componentCache['#{v[:widget_class_name]}'](#{region_widget_instance.js_config.to_js})".l]
    #     res << region_config
    #   end
    #   res
    # end
    
    def region_aggregatees
      aggregatees.reject{ |k,v| !REGIONS.include?(k) }
    end
    
    # def js_config
    #   super.merge(:regional_config => items)
    # end
  
    def interface_resize_region(params)
      @pref["#{params[:region_name]}_width"] = params[:new_width].to_i if params[:new_width]
      @pref["#{params[:region_name]}_height"] = params[:new_height].to_i if params[:new_height]
    end
    
    protected
  
    def extend_functions; ""; end
    def js_extra_events; ""; end
    
  end
end