class BookGridWithPaging < Netzke::Basepack::GridPanel
  js_property :title, "Books with paging"

  def default_config
    super.merge(
      :model => "Book",
      :rows_per_page => 2
    )
  end
end
