class Grid::Associations < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = 'Book'
    c.columns = [:title, :author__first_name, :author__prize_count]
  end
end
