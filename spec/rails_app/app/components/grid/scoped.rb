class Grid::Scoped < Netzke::Basepack::Grid
  def configure(c)
    c.model = "Book"
    c.load_inline_data = true
    super
    c.scope = lambda {|r| r.where(author_id: Author.first.try(:id))}
    c.strong_default_attrs = {:author_id => Author.first.id}
  end
end
