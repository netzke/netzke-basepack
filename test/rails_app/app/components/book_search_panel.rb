class BookSearchPanel < Netzke::Basepack::SearchPanel
  def default_config
    super.merge(:model => "Book", :persistence => true)
  end
end