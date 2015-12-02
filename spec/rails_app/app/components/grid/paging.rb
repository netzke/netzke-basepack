class Grid::Paging < Netzke::Basepack::Grid
  def configure(c)
    c.model = 'Book'
    c.paging = true
    c.store_config = { page_size: 2 }
    c.columns = [:title]
    super
  end
end
