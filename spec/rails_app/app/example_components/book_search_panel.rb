class BookSearchPanel < Netzke::Basepack::SearchPanel
  def configure(c)
    super
    c.model = 'Book'
    c.fields = [{name: 'exemplars', type: :integer, text: 'Exemplars'}, {name: 'title', type: :string, text: 'Title'}, {name: 'author__name', type: :string, text: 'Author name'}]
  end
end
