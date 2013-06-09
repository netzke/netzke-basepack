class Grid::Crud < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = 'Book'
    c.columns = [:author__name, :title]

    c.persistence = true
  end
end
