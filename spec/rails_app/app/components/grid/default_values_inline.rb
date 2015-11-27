class Grid::DefaultValuesInline < Grid::DefaultValues
  def configure(c)
    super
    c.edit_inline = true
  end
end
