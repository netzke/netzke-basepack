class Grid::MultilineEdit < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = "Book"
    c.edit_inline = true
  end
end
