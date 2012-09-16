class Viewport < Netzke::Base
  js_configure do |c|
    c.extend = "Ext.container.Viewport"
  end

  # In Ext 4.1 calling `render` on a viewport causes an error:
  #
  #   TypeError: protoEl is null
  def js_component_render
    ""
  end
end
