class SimpleWindow < Netzke::Basepack::Window
  js_properties :title => "My simple window"

  def default_config
    {
      :width => 400,
      :height => 300
    }
  end
end
