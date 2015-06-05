class Grid::Nested < Netzke::Base
  component :grid do |c|
    c.klass = Grid::ActionColumn
  end

  def configure(c)
    c.layout = :fit
    c.items = [:grid]
  end
end
