class Grid::LockingColumn < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = 'Book'
  end

  column :title do |c|
    c.locked = true
  end
end
