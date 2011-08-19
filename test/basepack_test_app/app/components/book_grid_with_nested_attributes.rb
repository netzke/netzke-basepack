class BookGridWithNestedAttributes < Netzke::Basepack::GridPanel
  def configuration
    super.merge(
      :model => "Book",
      :columns => [:title, {:name => :author__first_name, :nested_attribute => true}, {:name => :author__last_name, :nested_attribute => true}]
    )
  end

  def default_fields_for_forms
    [{:name => :title}, {:name => :author__first_name, :nested_attribute => true}, {:name => :author__last_name, :nested_attribute => true}]
  end

end
