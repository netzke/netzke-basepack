module Netzke
  class UserForm < Basepack::FormPanel
    def config
      {
        :model => 'User',
        :title => 'Users',
        :record_id => User.first.id,
        :items => [
          {:xtype => 'fieldset', :title => "Basic Info", :items => [:first_name, {:name => :last_name}]},
          {:xtype => 'fieldset', :title => "Timestamps", :items => [{:name => :created_at}, {:name => :updated_at}]},
          :role__name
        ]
      }.deep_merge super
    end
    
  end
end