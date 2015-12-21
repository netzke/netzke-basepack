class Grid::InlineEditing < Netzke::Grid::Base
  def configure(c)
    super
    c.model = 'Author'
    c.edit_inline = true
  end
end
