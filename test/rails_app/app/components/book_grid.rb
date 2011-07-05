class BookGrid < Netzke::Basepack::GridPanel

  js_property :title, "Books"

  def default_config
    super.merge(
      :model => "Book"
      # :persistence => true
      # :columns => [{:name => :author__first_name}]
      # :columns => [:title, :exemplars, :digitized, :notes]
    )
  end
end
