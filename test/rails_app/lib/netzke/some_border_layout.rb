module Netzke
  class SomeBorderLayout < Widget::BorderLayout
    def config
      {
        :items => [
          {:title => "Who", :class_name => "Widget::Panel", :region => :center},
          {:title => "Item Two", :class_name => "Widget::Panel", :region => :west, :width => 500, :split => true}
        ]
      }.deep_merge(super)
    end
  end
end