class BookGridWithNestedAttributes < Netzke::Basepack::Grid
  def configure(c)
    c.columns = [:title, {:name => :author__first_name, :nested_attribute => true}, {:name => :author__last_name, :nested_attribute => true}]
    c.model = "Book"
    super
  end

  # Override edit_window component in order to provide a custom list of fields for the form
  def edit_window_component(c)
    super
    c.form_config.items = [{:name => :title}, {:name => :author__first_name, :nested_attribute => true}, {:name => :author__last_name, :nested_attribute => true}]
  end
end
