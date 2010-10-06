module Netzke
  class SimpleWrapper < Component::Wrapper
    def config
      {
        :items => [{:class_name => "Component::Panel", :html => "A Panel wrapped into the (invisible) wrapper", :title => "Wrapped Panel"}]
      }
    end
  end
end