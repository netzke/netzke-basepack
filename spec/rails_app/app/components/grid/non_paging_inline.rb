class Grid::NonPagingInline < Netzke::Grid::Base
  def attributes
    [:title]
  end

  def configure(c)
    c.model = 'Book'
    c.paging = :none
    c.editing = :inline
    super
  end
end
