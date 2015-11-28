class Grid::Multisorting < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = 'Book'
    c.columns = [:author__last_name, :title, :exemplars]
    # c.paging = true
    c.store_config = {sorters: [:exemplars, :title, :author__last_name]}
  end
end
