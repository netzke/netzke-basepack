module Netzke
  class UserForm < Widget::FormPanel
    def default_config
      super.merge(
        :model => 'User',
        :title => 'Users',
        :items => [{:name => :first_name}, {:name => :last_name}, {
          :xtype => 'tabpanel', :items => [{
            :layout => 'form',
            :title => "Main",
            :items => [{:name => :first_name}]
          },{
            :layout => 'form',
            :title => "Extra",
            :items => [{:name => :last_name}]
          }],
          :active_tab => 0
          },{
            :xtype => 'fieldset', :checkbox_toggle => true, :title => "Fieldset", :items => [{:name => :first_name}, {:name => :last_name}]
        }]
      )
    end
  end
end