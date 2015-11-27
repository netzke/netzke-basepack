class GridWithDisabledEditing < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = 'Book'
    c.edit_inline = false
    c.edit_in_form = false
  end
end
