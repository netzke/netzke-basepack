class BookGrid < Netzke::Basepack::GridPanel
  title I18n.t('books', :default => "Books")

  model "Book"

  add_form_config :class_name => "BookForm"
  edit_form_config :class_name => "BookForm"
end
