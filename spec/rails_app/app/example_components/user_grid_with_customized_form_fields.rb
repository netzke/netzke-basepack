class UserGridWithCustomizedFormFields < Netzke::Grid::Base
  def configure(c)
    super
    c.title = "Users"
    c.model = "User"
  end

  def default_form_items
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
