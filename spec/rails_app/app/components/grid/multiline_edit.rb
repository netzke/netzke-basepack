class Grid::MultilineEdit < Netzke::Grid::Base
  def configure(c)
    super
    c.model = "Book"
    c.edit_inline = true
  end
end
