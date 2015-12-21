class BookGridWithCustomForms < Netzke::Grid::Base
  def configure(c)
    super
    c.model = "Book"
  end

  def default_form_items
    [
      {:xtype => 'fieldset', :title => "Basic Info", :checkboxToggle => true, :items => [
        :title,
        :exemplars
      ]},
      {:xtype => 'fieldset', :title => "Timestamps", :items => [
        {:name => :created_at, :disabled => true},
        {:name => :updated_at, :disabled => true}
      ]},
      :author__name
    ]
  end
end
