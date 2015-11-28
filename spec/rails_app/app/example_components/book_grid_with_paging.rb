class BookGridWithPaging < Netzke::Basepack::Grid
  def configure(c)
    c.model = "Book"
    c.title = "Books with paging"
    super
  end
end
