class Grid::Books < Netzke::Grid::Base
  def configure(c)
    super
    c.model = Book
  end
end
