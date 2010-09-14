module Netzke
  class SomeGridPanel < Widget::GridPanel
    def default_config
      super.merge(:model => "User")
    end
  end
end