class Grid::Buffered < Netzke::Grid::Base
  def configure(c)
    super
    c.model = 'Author'
    c.columns = [:first_name]
  end
end
