module Netzke
  class SomeBorderLayout < Widget::BorderLayout
    def config
      {
        :items => [
          {:title => "Who", :class_name => "Widget::GridPanel", :region => :center, :model => "User"},
          {:title => "Item Two", :class_name => "Widget::GridPanel", :region => :west, :width => 500, :split => true, :model => "Role"}
        ]
      }.deep_merge(super)
    end
  end
end