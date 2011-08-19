class BookGridWithDefaultValues < Netzke::Basepack::GridPanel
  js_property :title, "Books"

  def default_config
    super.merge(
      :model => "Book",
      :columns => [{:name => 'title', :default_value => "Lolita"}, {:name => 'author__last_name', :default_value => Author.first.id}, {:name => 'exemplars', :default_value => 100}, {:name => 'digitized', :default_value => true}]
    )
  end

end
