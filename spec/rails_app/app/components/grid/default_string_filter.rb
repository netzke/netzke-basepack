class Grid::DefaultStringFilter < Netzke::Basepack::Grid
  def columns
    [ :title, :author__first_name, :exemplars, :notes, :last_read_at, :digitized ]
  end

  def configure(c)
    super
    c.model = Book
    c.default_filters = [{column: :title, value: 'Brandstifter'}]
  end
end
