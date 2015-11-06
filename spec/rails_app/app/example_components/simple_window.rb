class SimpleWindow < Netzke::Basepack::Window
  client_class do |c|
    c.title = "My simple window"
  end

  def configure(c)
    super
    c.width = 400
    c.height = 300
  end
end
