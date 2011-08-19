class DoubleBookGrid < Netzke::Base
  js_property :layout, :border

  def configuration
    super.tap do |s|
      s[:items] = [{
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
end
