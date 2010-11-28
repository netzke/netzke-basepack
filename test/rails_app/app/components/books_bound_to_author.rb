class BooksBoundToAuthor < Netzke::Basepack::GridPanel
  def default_config
    super.merge(
      :model => "Book",
      :scope => {:author_id => Author.first.id},
      :strong_default_attrs => {:author_id => Author.first.id}
    )
  end
end
