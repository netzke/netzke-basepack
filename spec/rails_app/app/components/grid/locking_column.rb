class Grid::LockingColumn < Netzke::Grid::Base
  def model
    Book
  end

  column :title do |c|
    c.locked = true
  end
end
