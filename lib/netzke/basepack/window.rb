module Netzke
  module Basepack
    # Ext.window.Window-based component. With +persistence+ option set to +true+, it will remember it's size, position, and maximized state.
    #
    # Example:
    #
    #     class MyWindow < Netke::Basepack::Window
    #       def configure
    #         super
    #         c.width = 800
    #         c.height = 600
    #         c.items = [:users] # nesting the `users` component declared below
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
        [:x, :y, :width, :height].each { |p| c[p] = state[p].to_i if state[p] }
        c.maximized = state[:maximized] if state[:maximized]
      end

      endpoint :set_size_and_position do |params, this|
        [:x, :y, :width, :height].each {|p| state[p] = params[p].to_i}
      end

      endpoint :set_maximized do |maximized,this|
        maximized ? state[:maximized] = true : state.delete(:maximized)
      end
    end
  end
end
