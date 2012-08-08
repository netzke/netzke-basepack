class DoubleBookGrid < Netzke::Base
  js_configure do |c|
    c.layout = :border
  end

  def configure(c)
    super
    c.items = [{
      :region => :center,
      :class_name => "Netzke::Basepack::GridPanel",
      :model => "Book"
    },{
      :region => :south,
      :height => 200,
      :class_name => "Netzke::Basepack::GridPanel",
      :model => "Book"
    }]
  end
end
