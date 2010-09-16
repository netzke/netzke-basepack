module Netzke::Widget
  
  # Abstract widget that converts the passed items into aggregatees. 
  # Extend it and specify the desired layout.
  class Container < Base
    
    def aggregatees
      config[:items].nil? ? {} : begin
        config[:items].each_with_index.inject({}){ |r, (item, i)| r.merge(:"item#{i}" => item)}
      end
    end
    
    def js_config
      res = super
      
      # Detect inline aggregatees, and replace them with mere references
      detect_aggregatees_in_hash(res)
      
      res
    end
    
    private
      
      def detect_aggregatees_in_hash(hsh)
        detect_aggregatees_in_items(hsh[:items]) if hsh[:items]
      end

      def detect_aggregatees_in_items(items)
        items.each_with_index do |item, i|
          if item[:class_name]
            items[i] = js_aggregatee(:"item#{i}")
          else
            detect_aggregatees_in_hash(item)
          end
        end
      end
    
  end
end