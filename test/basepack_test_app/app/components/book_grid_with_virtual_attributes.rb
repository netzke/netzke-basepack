class BookGridWithVirtualAttributes < Netzke::Basepack::GridPanel
  js_property :title, "Books"

  include Extras::BookPresentation

  def default_config
    super.merge(
      :model => "Book",
      :columns => default_fields_for_forms
    )
  end

  def default_fields_for_forms
    [
      {:name => :title},
      {:name => :author__first_name, :setter => author_first_name_setter},
      {:name => :exemplars},
      {:name => :in_abundance, :getter => in_abundance_getter}
    ]
  end
end
