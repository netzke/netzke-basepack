module Netzke
  class UserGrid < Widget::GridPanel
    def config
      {
        :model => "User", :title => "Users"
      }.deep_merge super
    end
  end
end