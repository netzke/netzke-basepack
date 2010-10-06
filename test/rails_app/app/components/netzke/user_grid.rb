module Netzke
  class UserGrid < Basepack::GridPanel
  
    def config
      {
        :mode => :config,
        :model => "User",
        :title => "Users"
      }.deep_merge super
    end
  
    def search_panel
      {
        :class_name => "Basepack::FormPanel",
        :items => [{:name => :first_name.gt}]
      }
    end
  end
end