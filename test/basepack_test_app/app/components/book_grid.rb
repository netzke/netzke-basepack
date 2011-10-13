class BookGrid < Netzke::Basepack::GridPanel
  title I18n.t('books', :default => "Books")

  model "Book"

  # column :title
  # column :author__first_name
end
