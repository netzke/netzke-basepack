class Grid::DefaultDateFilter < Netzke::Basepack::Grid
  model "Book"

  def columns
    [ :title, :author__first_name, :exemplars, :notes, :last_read_at, :digitized ]
  end

  def configure(c)
    super
    c.default_filters = [{column: :last_read_at, value: {after: Date.parse("2011-01-01")}}]
  end
end
