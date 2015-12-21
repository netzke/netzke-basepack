class DoubleBookGrid < Netzke::Base
  client_class do |c|
    c.layout = :border
  end

  def configure(c)
    super
    c.items = [:first_grid, :second_grid]
  end

  component :first_grid do |c|
    c.klass = Netzke::Grid::Base
    c.region = :center
    c.model = "Book"
  end

  component :second_grid do |c|
    c.klass = Netzke::Grid::Base
    c.region = :south
    c.height = 200
    c.model = "Book"
  end
end
