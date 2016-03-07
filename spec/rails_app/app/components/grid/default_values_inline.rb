class Grid::DefaultValuesInline < Grid::DefaultValues
  def configure(c)
    super
    c.editing = :inline
  end
end
