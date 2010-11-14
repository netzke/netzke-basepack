class BookForm < Netzke::Basepack::FormPanel
  js_property :title, "Books"

  include BookPresentation

  def default_config
    super.merge(
      :model => "Book",
      :record => Book.first,
      :items => [
        :title,
        {:name => :author__first_name, :setter => author_first_name_setter},
        :exemplars,
        {:name => :in_abundance, :getter => in_abundance_getter}
      ]
    )
  end
end
