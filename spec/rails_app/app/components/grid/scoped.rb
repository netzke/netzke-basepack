class Grid::Scoped < Netzke::Basepack::Grid
  def configure(c)
    c.model = "Book"
    super
    c.scope = lambda {|r| r.where(author_id: Author.first.try(:id)) }
    c.strong_values = {:author_id => Author.first.id, notes: 'Fixed'}
  end
end
