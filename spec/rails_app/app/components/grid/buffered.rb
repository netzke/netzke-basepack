class Grid::Buffered < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = 'Author'
    c.columns = [:first_name]
  end
end
