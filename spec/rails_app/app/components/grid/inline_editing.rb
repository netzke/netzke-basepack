class Grid::InlineEditing < Netzke::Grid::Base
  def configure(c)
    super
    c.model = 'Author'
    c.editing = :inline
  end
end
