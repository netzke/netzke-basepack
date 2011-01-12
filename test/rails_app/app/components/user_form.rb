class UserForm < Netzke::Basepack::FormPanel
  js_property :title, User.model_name.human

  def configuration
    sup = super
    sup.merge({
      :model => 'User',
      :record_id => User.first.id,
      :items => [
        {:xtype => 'fieldset', :title => "Basic Info", :checkboxToggle => true, :items => [
          :first_name,
          {:name => :last_name}
        ]},
        {:xtype => 'fieldset', :title => "Timestamps", :items => [
          {:name => :created_at, :disabled => true},
          {:name => :updated_at, :disabled => true}
        ]},
        :role__name
      ]
    })
  end

  # Uncomment for visual mask testing
  # def netzke_submit_endpoint(params)
  #   sleep 2
  #   super
  # end
end
