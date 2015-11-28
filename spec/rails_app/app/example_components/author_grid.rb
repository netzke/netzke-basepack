class AuthorGrid < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = "Author"
  end
end
