class BookGridDefaultFiltering < Netzke::Basepack::Grid
  model "Book"

  def columns
    [ :title, :author__first_name, :exemplars, :notes, :last_read_at, :digitized ]
  end

  def configure(c)
    super
    c.defaultFilters = [{column: :title, value: 'Brandstifter'}]
  end
end
