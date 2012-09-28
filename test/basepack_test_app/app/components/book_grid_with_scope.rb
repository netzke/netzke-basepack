class BookGridWithScope < BookGrid
  def configure(c)
    super
    c.scope = lambda {|r| r.where(author_id: Author.first.try(:id))}
  end
end
