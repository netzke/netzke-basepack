class BookGrid < Netzke::Basepack::GridPanel
  title I18n.t('books', :default => "Books")

  model "Book"

  add_form_config :class_name => "BookForm"
  edit_form_config :class_name => "BookForm"
  multi_edit_form_config :class_name => "BookForm"

  # We need to specify how we want to sort on this virtual column:
  #override_column :author__name, :sorting_scope => :sorted_by_author_name

  column :author__name do |c|
    c.sorting_scope = :sorted_by_author_name
  end

  #def configure
    #super
    #config.columns = [:author__name, :title, :created_at]
  #end
end
