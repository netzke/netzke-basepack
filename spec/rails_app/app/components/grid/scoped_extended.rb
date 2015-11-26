class Grid::ScopedExtended < Grid::Scoped
  def configure(c)
    super
    super_scope = c.scope
    c.scope = lambda { |r| super_scope.call(r).where("title like '%Ix%'") }
  end
end
