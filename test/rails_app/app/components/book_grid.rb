class BookGrid < Netzke::Basepack::GridPanel
  js_property :title, "Books"

  def default_config
    super.merge(
      :model => "Book"
    )
  end
end
