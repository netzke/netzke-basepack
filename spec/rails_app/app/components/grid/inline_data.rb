class Grid::InlineData < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = "Book"
    c.load_inline_data = true
  end
end
