module Netzke
  class UserGrid < Widget::GridPanel
    def default_config
      super.merge(:model => "User", :title => "Users")
    end
  end
end