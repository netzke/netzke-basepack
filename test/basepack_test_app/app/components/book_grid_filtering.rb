class BookGridFiltering < Netzke::Basepack::GridPanel
  model "Book"

  column :title
  column :author__first_name
  column :exemplars
  column :notes
  column :last_read_at
  column :digitized
end
