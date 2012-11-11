module Netzke
  module Basepack
    # When mixed into a component with resizable layout (e.g. border layout), this module enables persistence for regions size and collapsed/expanded state.
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

      def extend_item(item)
        item = super

        item_id = item[:netzke_component] || item[:item_id] # identify regions by item_id

        if item_id
          item[:width] = state[:"#{item_id}_width"] || item[:width]
          item[:height] = state[:"#{item_id}_height"] || item[:height]

          if state[:"#{item_id}_collapsed"].present?
            item[:collapsed] = state[:"#{item_id}_collapsed"]
          end
        end

        item
      end
    end
  end
end
