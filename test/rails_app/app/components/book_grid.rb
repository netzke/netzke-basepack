class BookGrid < Netzke::Basepack::GridPanel
  js_property :title, I18n.t('books', :default => "Books")

  def default_config
    super.merge(
      :model => "Book"
      # :columns => [{:name => :author__first_name}]
      # :columns => [:title, :exemplars, :digitized, :notes]
    )
  end
end
