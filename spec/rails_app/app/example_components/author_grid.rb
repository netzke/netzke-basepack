class AuthorGrid < Netzke::Grid::Base
  def configure(c)
    super
    c.model = "Author"
  end
end
