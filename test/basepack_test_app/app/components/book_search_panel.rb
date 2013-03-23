class BookSearchPanel < Netzke::Basepack::SearchPanel
  def configure(c)
    super
    c.model = 'Book'
    c.fields = [{name: 'exemplars', attr_type: :integer, text: 'Exemplars'}, {name: 'title', attr_type: :string, text: 'Title'}, {name: 'author__name', attr_type: :string, text: 'Author name'}]
  end
end
