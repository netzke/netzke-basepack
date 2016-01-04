class Grid::ScopedWithHash < Netzke::Grid::Base
  def configure(c)
    super
    c.model = Book
    c.scope = {title: "One"}
  end
end
