class Grid::Pagination < Netzke::Basepack::Grid
  def configure(c)
    c.model = 'Book'
    c.rows_per_page = 2
    super
  end
end
