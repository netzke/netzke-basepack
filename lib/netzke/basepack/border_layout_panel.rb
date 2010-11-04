module Netzke
  module Basepack
    # Panel with border layout
    # == Example configuration:
    #
    #     :items => [
    #       {:title => "Item One", :class_name => "Basepack::Panel", :region => :center},
    #       {:title => "Item Two", :class_name => "Basepack::Panel", :region => :west, :width => 300, :split => true}
    #     ]
    class BorderLayoutPanel < Netzke::Base
      def items
        @border_layout_items ||= begin
          updated_items = super

          if config[:persistence]
            updated_items.each do |item|
              region = item[:region] || components[item[:component]][:region]
              item.merge!({
                :width => state["#{region}_region_width"],
                :height => state["#{region}_region_height"],
                :collapsed => state["#{region}_region_collapsed"]
              })
            end
          end
          
          updated_items
        end
      end
      
      js_property :layout, :border
      
      js_method :init_component, <<-JS
        function(){
          Ext.each(['center', 'west', 'east', 'south', 'north'], function(r){
            // A function to access a region component (even if the component gets reloaded, the function will work).
            // E.g.: getEastComponent()
            var methodName = 'get'+r.capitalize()+'Component';
            this[methodName] = function(){
              Netzke.deprecationWarning("Instead of '" + methodName + "' use getChildComponent('<name of your component>').");
              return this.find('region', r)[0];
            }.createDelegate(this);
          }, this);

          // Now let Ext.Panel do the rest
          #{js_full_class_name}.superclass.initComponent.call(this);

          // First time on "afterlayout", set resize events
          if (this.persistence) {this.on('afterlayout', this.setRegionEvents, this, {single: true});}
        }
      JS
      
      js_method :set_region_events, <<-JS
        function(){
          this.items.each(function(item, index, length){
            if (!item.oldSize) item.oldSize = item.getSize(); // remember initial size
              
            item.on('resize', function(panel, w, h){
              if (panel.region !== 'center' && w && h) {
                var params = {region:panel.region};
              
                if (panel.oldSize.width != w) {
                  params.width = w;
                } else {
                  params.height = h;
                }
              
                panel.oldSize = panel.getSize();
                this.regionResized(params);
              }
            }, this);

            item.on('collapse', function(panel){
              this.regionCollapsed({region: panel.region});
            }, this);
            
            item.on('expand', function(panel){
              this.regionExpanded({region: panel.region});
            }, this);
            
          }, this);
        }
      JS

      endpoint :region_resized do |params|
        size_state_hash = {}
        size_state_hash[:"#{params[:region]}_region_width"] = params[:width] if params[:width]
        size_state_hash[:"#{params[:region]}_region_height"] = params[:height] if params[:height]
        update_state(size_state_hash)
      end

      endpoint :region_collapsed do |params|
        update_state(:"#{params[:region]}_region_collapsed" => true)
      end

      endpoint :region_expanded do |params|
        update_state(:"#{params[:region]}_region_collapsed" => false)
      end

    end
  end
end