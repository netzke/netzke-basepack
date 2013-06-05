class Grid::Sorting < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = 'Book'
  end
end
