class BookSearchPanel < Netzke::Basepack::NewSearchPanel
  def default_config
    super.merge(:model => "Book")
  end
end