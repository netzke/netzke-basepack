module Netzke
  class UserForm < Component::FormPanel
    def config
      {
        :model => 'User',
        :title => 'Users',
        :record_id => User.first.id,
        :items => [
          {:xtype => 'fieldset', :checkbox_toggle => false, :title => "Basic Info", :items => [{:name => :first_name}, {:name => :last_name}]},
          {:xtype => 'fieldset', :checkbox_toggle => false, :title => "Timestamps", :items => [{:name => :created_at}, {:name => :updated_at}]},
          {:name => :role__name}
        ]
      }.deep_merge super
    end
    
  end
end