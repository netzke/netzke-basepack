class BookGridWithDefaultValues < Netzke::Basepack::GridPanel
  model "Book"
  js_property :title, "Books"

  column :title, :default_value => "Lolita"
  column :author__last_name, :default_value => Author.first.id
  column :exemplars, :default_value => 100
  column :digitized, :default_value => true
end
