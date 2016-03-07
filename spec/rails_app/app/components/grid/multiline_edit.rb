class Grid::MultilineEdit < Netzke::Grid::Base
  def configure(c)
    super
    c.model = "Book"
    c.editing = :inline
  end
end
