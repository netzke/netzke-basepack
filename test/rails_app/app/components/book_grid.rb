class BookGrid < Netzke::Basepack::GridPanel

  js_property :title, "Books"

  def default_config
    super.merge(
      :model => "Book",
      # :rows_per_page => 3
      # :persistence => true
      # :columns => [{:name => :author__first_name}]
    )
  end
end
