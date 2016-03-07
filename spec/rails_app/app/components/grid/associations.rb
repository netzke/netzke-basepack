class Grid::Associations < Netzke::Grid::Base
  def configure(c)
    super
    c.model = 'Book'
    c.editing = :inline
    c.columns = [:title, :author__first_name, :author__prize_count]
  end
end
