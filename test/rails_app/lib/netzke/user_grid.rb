module Netzke
  class UserGrid < Widget::GridPanel
    def config
      {
        :mode => :config,
        :model => "User",
        :title => "Users",
        :query => ["id < ?", 8]
      }.deep_merge super
    end
  end
end