class GridWithDisabledEditing < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = 'Book'
    c.enable_edit_inline = false
    c.enable_edit_in_form = false
  end
end
