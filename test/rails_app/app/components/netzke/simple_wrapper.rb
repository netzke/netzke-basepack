module Netzke
  class SimpleWrapper < Basepack::Wrapper
    def config
      {
        :items => [{:class_name => "Basepack::Panel", :html => "A Panel wrapped into the (invisible) wrapper", :title => "Wrapped Panel"}]
      }
    end
  end
end