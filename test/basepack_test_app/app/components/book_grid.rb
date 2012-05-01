class BookGrid < Netzke::Basepack::GridPanel
  title I18n.t('books', :default => "Books")

  model "Book"

  add_form_config :class_name => "BookForm"
  edit_form_config :class_name => "BookForm"
  multi_edit_form_config :class_name => "BookForm"

  column :author__name do |c|
    c.sorting_scope = :sorted_by_author_name
  end
end
