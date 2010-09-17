module Netzke
  class SimpleWrapper < Widget::Wrapper
    def config
      {
        :items => [{:class_name => "Widget::Panel", :html => "A Panel wrapped into the (invisible) wrapper", :title => "Wrapped Panel"}]
      }
    end
  end
end