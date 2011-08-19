# Grid with books that belong to the first author in the DB (assumes the existence of at least 1 author)
class BooksBoundToAuthor < Netzke::Basepack::GridPanel
  def default_config
    super.merge(
      :model => "Book",
      :scope => {:author_id => Author.first.id},
      :strong_default_attrs => {:author_id => Author.first.id}
    )
  end
end
