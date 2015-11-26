class AuthorGrid < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = "Author"
    c.scope = ->(r) { r.order(:first_name) }
  end
end
