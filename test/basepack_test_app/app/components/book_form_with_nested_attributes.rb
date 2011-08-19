class BookFormWithNestedAttributes < Netzke::Basepack::FormPanel
  js_property :title, Book.model_name.human

  def default_config
    super.merge(
      :model => "Book",
      :record => Book.first,
      :items => [
        :title,
        {:name => :author__first_name, :nested_attribute => true},
        {:name => :author__last_name, :nested_attribute => true},
        :digitized,
        :exemplars
      ]
    )
  end

end
