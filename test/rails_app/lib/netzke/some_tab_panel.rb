module Netzke
  class SomeTabPanel < Component::TabPanel
    def config
      {
        :active_tab => 0,
        :items => [{
          :title => "User form",
          :class_name => "UserForm",
          :record_id => User.first.id
        },{
          :title => "User grid",
          :class_name => "UserGrid"
        }]
      }.deep_merge super
    end
  end
end