class BookGridFiltering < Netzke::Basepack::GridPanel
  model "Book"

  def columns
    [ :title, :author__first_name, :exemplars, :notes, :last_read_at, :digitized ]
  end
end
