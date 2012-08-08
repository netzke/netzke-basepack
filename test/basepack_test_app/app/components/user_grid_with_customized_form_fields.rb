class UserGridWithCustomizedFormFields < Netzke::Basepack::GridPanel
  def configure(c)
    c.title = "Users"
    c.model = "User"
  end

  def default_fields_for_forms
    [
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
end
