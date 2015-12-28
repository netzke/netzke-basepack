class Grid::Search < Netzke::Grid::Base
  def model
    Book
  end

  def columns
    [:author__last_name, :title, :exemplars]
  end
end
