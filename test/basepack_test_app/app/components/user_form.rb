class UserForm < Netzke::Basepack::FormPanel
  def configure(c)
    super
    c.title = User.model_name.human
    c.items = [
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
  end

  model "User"

  record_id User.first.try(:id)

  # Uncomment for visual mask testing
  # def netzke_submit_endpoint(params)
  #   sleep 2
  #   super
  # end
end
