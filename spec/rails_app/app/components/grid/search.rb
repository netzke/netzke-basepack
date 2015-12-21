class Grid::Search < Netzke::Grid::Base
  def configure(c)
    super
    c.model = 'Book'

    c.columns = [:author__last_name, :title, :exemplars]
  end
end
