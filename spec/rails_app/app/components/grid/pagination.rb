class Grid::Pagination < Netzke::Grid::Base
  def model
    Book
  end

  def attributes
    [:title]
  end

  def configure(c)
    super
    c.paging = :pagination
  end
end
