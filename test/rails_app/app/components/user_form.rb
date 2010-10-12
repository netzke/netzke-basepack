class UserForm < Netzke::Basepack::FormPanel
  def config
    {
      :model => 'User',
      :title => 'Users',
      :record_id => User.first.id,
      # :items => [
      #   {:xtype => 'fieldset', :title => "Basic Info", :checkboxToggle => true, :items => [:first_name, {:name => :last_name}]},
      #   {:xtype => 'fieldset', :title => "Timestamps", :items => [{:name => :created_at, :disabled => true}, {:name => :updated_at, :disabled => true}]},
      #   :role__name
      # ]
    }.deep_merge super
  end
end
