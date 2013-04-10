class BookGridDateDefaultFiltering < Netzke::Basepack::Grid
  model "Book"

  def columns
    [ :title, :author__first_name, :exemplars, :notes, :last_read_at, :digitized ]
  end

  def configure(c)
    super
    c.defaultFilters = [{column: :last_read_at, value: {after: Date.parse("2011-01-01")}}]
  end
end
