module Netzke
  module Basepack
    # Ext.window.Window-based component. With +persistence+ option set to +true+, it will remember it's size and position.
    #
    # Example:
    #
    #     class MyWindow < Netke::Basepack::Window
    #       def configure
    #         super
    #         c.width = 800
    #         c.height = 600
    #         c.items = [:users]
    #       end
    #
    #       component :users
    #     end
    class Window < Netzke::Base
      js_configure do |c|
        c.extend = "Ext.window.Window"
        c.mixin
      end

      def js_configure(c)
        super
        c.x = state[:x].to_i if state[:x]
        c.y = state[:y].to_i if state[:y]
        c.width = state[:w].to_i if state[:w]
        c.height = state[:h].to_i if state[:h]
      end

      endpoint :set_size_and_position do |params, this|
        update_state(:x, params[:x].to_i)
        update_state(:y, params[:y].to_i)
        update_state(:w, params[:w].to_i)
        update_state(:h, params[:h].to_i)
      end
    end
  end
end
