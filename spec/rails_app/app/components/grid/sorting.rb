class Grid::Sorting < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = 'Book'
    c.columns = [:author__last_name, :title, :exemplars]
    c.store_config = {sorters: {property: :exemplars, direction: 'DESC'}}
  end
end
