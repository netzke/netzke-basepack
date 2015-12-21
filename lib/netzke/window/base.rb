module Netzke
  module Window
    # Ext.window.Window-based component. With +persistence+ option set to +true+, it will remember it's size, position, and maximized state.
    #
    # Example:
    #
    #     class MyWindow < Netke::Window::Base
    #       def configure
    #         super
    #         c.width = 800
    #         c.height = 600
    #         c.items = [:users] # nesting the `users` component declared below
    #       end
    #
    #       component :users
    #     end
    class Base < Netzke::Base
      client_class do |c|
        c.extend = "Ext.window.Window"
      end

      def configure_client(c)
        super
        [:x, :y, :width, :height].each { |p| c[p] = state[p].to_i if state[p] }
        c.maximized = state[:maximized] if state[:maximized]
      end

      endpoint :set_size_and_position do |params|
        [:x, :y, :width, :height].each {|p| state[p] = params[p].to_i}
      end

      endpoint :set_maximized do |maximized|
        maximized ? state[:maximized] = true : state.delete(:maximized)
      end
    end
  end
end
