module Netzke
  module Component
    # Panel with border layout
    # == Example configuration:
    # 
    #     :items => [
    #       {:title => "Item One", :class_name => "Basepack::Panel", :region => :center},
    #       {:title => "Item Two", :class_name => "Basepack::Panel", :region => :west, :width => 300, :split => true}
    #     ]
    class BorderLayoutPanel < Base
      
      def self.js_properties
        {
          :layout => 'border',
          :init_component => <<-END_OF_JAVASCRIPT.l,
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
              if (this.persistentConfig) {this.on('afterlayout', this.setResizeEvents, this, {single: true});}
            }
          END_OF_JAVASCRIPT
        }
      end

    end
  end
end