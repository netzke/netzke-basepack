class Grid::LockingColumn < Netzke::Grid::Base
  def configure(c)
    super
    c.model = 'Book'
  end

  column :title do |c|
    c.locked = true
  end
end
