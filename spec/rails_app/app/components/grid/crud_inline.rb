class Grid::CrudInline < Grid::Crud
  def configure(c)
    super
    c.editing = :inline
  end
end
