module Netzke::Widget
  
  # Abstract widget that converts the passed items into aggregatees. 
  # Extend it and specify the desired layout.
  module Container
    
    def aggregatees_with_container
      config[:items].nil? ? {} : begin
        config[:items].select{ |item| item[:class_name]}.each_with_index.inject({}){ |r, (item, i)| r.merge(:"item#{i}" => item)}
      end
    end
    
    def js_config_with_container
      res = js_config_without_container
      
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
      
    def self.included(receiver)
      receiver.alias_method_chain :aggregatees, :container
      receiver.alias_method_chain :js_config, :container
    end
    
  end
end
