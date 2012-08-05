class BookGridWithNestedAttributes < Netzke::Basepack::GridPanel
  model "Book"

  def configure(c)
    super
    c.columns = [:title, {:name => :author__first_name, :nested_attribute => true}, {:name => :author__last_name, :nested_attribute => true}]
  end

  # Override edit_window component in order to provide a custom list of fields for the form
  def edit_window_component(c)
    super
    c.form_config.items = [{:name => :title}, {:name => :author__first_name, :nested_attribute => true}, {:name => :author__last_name, :nested_attribute => true}]
  end
end
