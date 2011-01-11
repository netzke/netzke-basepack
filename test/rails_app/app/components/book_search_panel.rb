class BookSearchPanel < Netzke::Basepack::NewSearchPanel
  def default_config
    super.merge(:model => "Book", :persistence => true)
  end
end