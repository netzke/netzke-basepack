class Grid::InlineEditing < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = 'Author'
    c.edit_inline = true
  end
end
