class Grid::CrudInline < Grid::Crud
  def configure(c)
    super
    c.edit_inline = true
  end
end
