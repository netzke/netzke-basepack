class DoubleBookGrid < Netzke::Base
  js_property :layout, :border

  def configure
    super
    @config[:items] = [{
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
