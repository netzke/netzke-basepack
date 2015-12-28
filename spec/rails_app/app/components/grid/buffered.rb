class Grid::Buffered < Netzke::Grid::Base
  def model
    Author
  end

  def columns
    [:first_name]
  end
end
