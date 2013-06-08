class Grid::Search < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = 'Book'

    c.columns = [:author__last_name, :title, :exemplars]
  end
end
