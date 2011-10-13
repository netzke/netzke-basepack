class BookGrid < Netzke::Basepack::GridPanel
  js_property :title, I18n.t('books', :default => "Books")

  model "Book"

  # column :title
  # column :author__first_name
end
