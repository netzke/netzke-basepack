class GridWithInitialSorting < Netzke::Basepack::GridPanel
  def configure(c)
    super
    c.model = "Book"
    c.data_store.sorters = {property: :title, direction: 'DESC'}
  end
end
