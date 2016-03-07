class Grid::PaginationInline < Netzke::Grid::Base
  def model
    Book
  end

  def columns
    [:title]
  end

  def configure(c)
    super
    c.paging = :pagination
    c.editing = :inline
  end
end
