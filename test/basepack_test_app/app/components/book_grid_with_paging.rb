class BookGridWithPaging < Netzke::Basepack::GridPanel
  model "Book"

  def configure(c)
    super
    c.title = "Books with paging"
    c.rows_per_page = 2
  end
end
