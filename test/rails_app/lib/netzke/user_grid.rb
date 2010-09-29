module Netzke
  class UserGrid < Component::GridPanel
    
    def config
      {
        :mode => :config,
        :model => "User",
        :title => "Users",
        :columns => [:first_name, :last_name, :role__name]
      }.deep_merge super
    end
  end
end