class BookSearchPanel < Netzke::Basepack::SearchPanel
  js_mixin :i18n_de

  def default_config
    super.merge(:model => "Book", :persistence => true)
  end
end
