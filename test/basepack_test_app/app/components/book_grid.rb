class BookGrid < Netzke::Basepack::GridPanel
  title I18n.t('books', :default => "Books")

  model "Book"

  # column :title
  # override_column :author__name, :editable => false
end
