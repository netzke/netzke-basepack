module Netzke
  # Represents the Ext.Panel with layout 'border'. May serve as parent class for compound components.
  # 
  # == Features:
  # * Responds to region resizing, storing the sizes in persistent config
  # 
  # == Future features:
  # * Stores expand/collapse state in the persistent config
  # 
  # == Non-functional features:
  # * (JavaScript) Creates convinient methods to access components inside the regions, like
  # <tt>getCenterComponent()</tt>, <tt>getWestComponent()</tt>, etc
  # 
  # == Configuration:
  # <tt>:regions</tt> - a hash in form:
  #       
  #     {:center => {<netzke component config>}, :east => {<another netzke component config>}, ...}
  # 
  # <tt>:regions => :center/:west/:etc => :region_config</tt> - configuration options for
  # Ext.layout.BorderLayout.SplitRegion.
  #     
  # == Example configuration:
  # 
  #     :regions => {
  #       :center => {:class_name => "Panel", :ext_config => {:html => "A panel"}}, 
  #       :west => {
  #         :class_name => "GridPanel", 
  #         :model => "User", 
  #         :region_config => {
  #           :width => 100,
  #           :split => true
  #         }
  #       }
  #     }
  class BorderLayoutPanel < Component::Base
    REGIONS = %w(center west east south north).map(&:to_sym)

    # JavaScript part
    def self.js_properties
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
                var klass = this.classifyScopedName(this[configName].scopedClassName);
                regionConfig.items = [new klass(this[configName])]
                this.items.push(regionConfig);

                // A function to access a region component (even if the component gets reloaded, the function will work).
                // E.g.: getEastComponent()
                this['get'+r.capitalize()+'Component'] = function(){
                  return this.find('region', r)[0].getNetzkeComponent()
                }.createDelegate(this);
              };
            }, this);
            
            // Now let Ext.Panel do the rest
            #{js_full_class_name}.superclass.initComponent.call(this);
            
            // First time on "afterlayout", set resize events
            if (this.persistentConfig) {this.on('afterlayout', this.setResizeEvents, this, {single: true});}
          }
        END_OF_JAVASCRIPT
        
        :get_region_component => <<-END_OF_JAVASCRIPT.l,
          function(region){
            return this.find('region', region)[0].getNetzkeComponent();
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
        }
      END_OF_JAVASCRIPT
    }
    end

    def initial_components
      config[:regions] || {}
    end
    
    def region_components
      components.reject{ |k,v| !REGIONS.include?(k) }
    end
    
    def js_config
      regions = {}
      REGIONS.each do |r|
        if region_aggr = components[r]
          regions.merge!(r => region_aggr[:region_config] || {})
        end
      end
      super.merge(:regions => regions)
    end

    # API
    api :resize_region # handles regions resize
    def resize_region(params)
      # Write to persistent_config such way that these settings are automatically picked up by region components
      persistent_config["regions__#{params["region_name"]}__region_config__width"] = params["new_width"].to_i if params["new_width"]
      persistent_config["regions__#{params["region_name"]}__region_config__height"] = params["new_height"].to_i if params["new_height"]
      {}
    end
    
  end
end