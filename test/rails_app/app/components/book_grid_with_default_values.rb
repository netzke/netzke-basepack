class BookGridWithDefaultValues < Netzke::Basepack::GridPanel
  js_property :title, "Books"

  def default_config
    super.merge(
      :model => "Book",
      :columns => [{:name => 'author__last_name', :default_value => Author.first.id}, {:name => 'title', :default_value => "Lolita"}, {:name => 'exemplars', :default_value => 100}, {:name => 'digitized', :default_value => true}]
    )
  end

end
