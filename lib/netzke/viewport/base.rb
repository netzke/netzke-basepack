module Netzke
  module Viewport
    class Base < Netzke::Base
      client_class do |c|
        c.extend = "Ext.container.Viewport"
      end

      # In Ext 4.1 calling `render` on a viewport causes an error:
      #
      #   TypeError: protoEl is null
      def js_component_render
        ""
      end
    end
  end
end
