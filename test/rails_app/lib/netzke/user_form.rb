module Netzke
  class UserForm < Widget::FormPanel
    def config
      {
        :model => 'User',
        :title => 'Users',
        :record => User.first,
        :items => [
          # {:name => :first_name, :disabled => true}, {:name => :last_name}, 
          # { 
          #   :xtype => 'tabpanel', :items => [{
          #     :layout => 'form',
          #     :title => "Main",
          #     :padding => 5,
          #     :auto_height => true,
          #     :items => [{:name => :first_name}]
          #   },{
          #     :layout => 'form',
          #     :title => "Extra",
          #     :padding => 5,
          #     :auto_height => true,
          #     :items => [{:name => :last_name}]
          #   }],
          #   :active_tab => 0
          # },
          { :xtype => 'fieldset', :checkbox_toggle => false, :title => "Fieldset", :items => [{:name => :first_name}, {:name => :last_name}]
        }]
      }.deep_merge super
    end
  end
end