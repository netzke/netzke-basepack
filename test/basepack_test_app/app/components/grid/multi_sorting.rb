class Grid::MultiSorting < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = 'Book'
    c.columns = [:author__last_name, :title, :exemplars]
    c.data_store.sorters = [:exemplars, :title, :author__last_name]
  end
end
