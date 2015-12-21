class UserForm < Netzke::Form::Base
  def configure(c)
    c.record = User.first

    super

    c.model = "User"
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
      { name: :role__name, empty_text: "Select a role" }
    ]
  end

  # Uncomment for visual mask testing
  # def submit_endpoint(params)
  #   sleep 2
  #   super
  # end
end
