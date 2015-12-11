# Grid with books that belong to the first author in the DB (assumes the existence of at least 1 author)
class BooksBoundToAuthor < Netzke::Basepack::Grid
  def configure(c)
    c.model = Book
    c.scope = {:author_id => Author.first.id}
    c.strong_values = {:author_id => Author.first.id}
    super
  end
end
