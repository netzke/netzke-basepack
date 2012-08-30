module Netzke
  module Basepack
    module ItemsPersistence
      extend ActiveSupport::Concern

      included do
        # this plugins does the job of assigning resize/collapse events for the component
        plugin :events_plugin do |c|
          c.klass = EventsPlugin
        end

        # Added endpoints
        endpoint :region_resized do |params, this|
          update_state(:"#{params[:item]}_width", params[:width].to_i) if params[:width]
          update_state(:"#{params[:item]}_height", params[:height].to_i) if params[:height]
        end

        endpoint :region_collapsed do |params, this|
          update_state :"#{params[:item]}_collapsed", true
        end

        endpoint :region_expanded do |params, this|
          update_state :"#{params[:item]}_collapsed", false
        end
      end

      # Override js_items to add the size/collapse state options to each item
      def js_items
        super.map do |item|
          # normalize first
          new_item = item.is_a?(Hash) ? item.dup : {netzke_component: item}

          item_id = new_item[:netzke_component]

          new_item[:width] = state[:"#{item_id}_width"] || new_item[:width]
          new_item[:height] = state[:"#{item_id}_height"] || new_item[:height]

          if state[:"#{item_id}_collapsed"].present?
            new_item[:collapsed] = state[:"#{item_id}_collapsed"]
          end

          new_item
        end
      end
    end
  end
end
