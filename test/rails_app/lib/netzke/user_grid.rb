module Netzke
  class UserGrid < Component::GridPanel
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