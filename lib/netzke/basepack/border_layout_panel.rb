module Netzke
  module Basepack
    # Panel with border layout.
    #
    # == Features
    #   * When persistence enabled, remembers the sizes and collapsed/expanded states of its regions.
    #
    # == Example configuration:
    #
    #   class MyBorderLayoutPanel < Netzke::Basepack::BorderLayoutPanel
    #     items [
    #       {title: "Item One", class_name: "Basepack::Panel", region: :center},
    #       {title: "Item Two", class_name: "Basepack::Panel", region: :west, width: 300, split: true}
    #     ]
    #   end
    class BorderLayoutPanel < Netzke::Base
      js_configure do |c|
        c.mixin
      end

      def items
        return @blp_items unless @blp_items.nil?

        @blp_items = super.clone

        @blp_items.each do |item|
          region = item[:region] || components[item[:netzke_component]][:region]
          next if region == :center

          item[:width] = state[:"#{region}_region_width"] || item[:width]
          item[:height] = state[:"#{region}_region_height"] || item[:height]

          if state[:"#{region}_region_collapsed"].present?
            item[:collapsed] = state[:"#{region}_region_collapsed"]
          end
        end
      end

      endpoint :region_resized do |params|
        update_state(:"#{params[:region]}_region_width", params[:width].to_i) if params[:width]
        update_state(:"#{params[:region]}_region_height", params[:height].to_i) if params[:height]
      end

      endpoint :region_collapsed do |params|
        update_state :"#{params[:region]}_region_collapsed", true
      end

      endpoint :region_expanded do |params|
        update_state :"#{params[:region]}_region_collapsed", false
      end
    end
  end
end
