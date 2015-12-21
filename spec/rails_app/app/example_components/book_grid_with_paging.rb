class BookGridWithPaging < Netzke::Grid::Base
  def configure(c)
    c.model = "Book"
    c.title = "Books with paging"
    super
  end
end
