module Netzke
  module Basepack
    # Panel with border layout.
    #
    # == Features
    #   * When persistence enabled, remembers the sizes and collapsed/expanded states of its regions.
    #
    # == Example configuration:
    #
    #     :items => [
    #       {:title => "Item One", :class_name => "Basepack::Panel", :region => :center},
    #       {:title => "Item Two", :class_name => "Basepack::Panel", :region => :west, :width => 300, :split => true}
    #     ]
    class BorderLayoutPanel < Netzke::Base
      js_mixin :border_layout_panel

      def items
        @border_layout_items ||= begin
          updated_items = super

          if config[:persistence]
            updated_items.each do |item|
              region = item[:region] || components[item[:netzke_component]][:region]
              item.merge!({
                :width => state[:"#{region}_region_width"],
                :height => state[:"#{region}_region_height"],
                :collapsed => state[:"#{region}_region_collapsed"]
              })
            end
          end

          updated_items
        end
      end

      endpoint :region_resized do |params|
        size_state_hash = {}
        size_state_hash[:"#{params[:region]}_region_width"] = params[:width].to_i if params[:width]
        size_state_hash[:"#{params[:region]}_region_height"] = params[:height].to_i if params[:height]
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