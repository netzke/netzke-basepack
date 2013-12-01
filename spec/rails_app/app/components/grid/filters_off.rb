class Grid::FiltersOff < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = "Book"
    c.enable_column_filters = false
  end
end
