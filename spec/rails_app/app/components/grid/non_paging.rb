class Grid::NonPaging < Netzke::Grid::Base
  def attributes
    [:title]
  end

  def configure(c)
    c.model = 'Book'
    c.paging = :none
    super
  end
end
