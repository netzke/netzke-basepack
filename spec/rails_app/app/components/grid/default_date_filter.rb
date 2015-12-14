class Grid::DefaultDateFilter < Netzke::Basepack::Grid
  def columns
    [ :title, :author__first_name, :exemplars, :notes, :last_read_at, :digitized ]
  end

  def configure(c)
    super
    c.model = Book
    c.default_filters = [{column: :last_read_at, value: {gt: Date.parse("2011-01-01")}}]
  end
end
