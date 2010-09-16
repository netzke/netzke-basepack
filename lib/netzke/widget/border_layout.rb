module Netzke
  module Widget
    
    # Panel with border layout
    # == Example configuration:
    # 
    #     :items => [
    #       {:title => "Item One", :class_name => "Widget::Panel", :region => :center},
    #       {:title => "Item Two", :class_name => "Widget::Panel", :region => :west, :width => 300, :split => true}
    #     ]
    class BorderLayout < Base
      
      include Container
      
      def self.js_properties
        {
          :layout => 'border'
        }
      end

    end
  end
end