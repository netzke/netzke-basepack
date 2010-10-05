module Netzke
  class UserGrid < Component::GridPanel
  
    def config
      {
        :mode => :config,
        :model => "User",
        :title => "Users!..",
        # :columns => [:first_name, :last_name, {:name => :role__name, :editor => {:xtype => 'combobox'}}]
      }.deep_merge super
    end
  
    def search_panel
      {
        :class_name => "Component::FormPanel",
        :items => [{:name => :first_name.gt}]
      }
    end
  end
end