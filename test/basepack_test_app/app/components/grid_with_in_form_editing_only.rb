class GridWithInFormEditingOnly < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = 'Book'
    c.enable_edit_inline = false
  end
end
