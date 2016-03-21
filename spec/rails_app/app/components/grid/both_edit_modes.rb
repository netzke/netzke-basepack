class Grid::BothEditModes < Netzke::Grid::Base
  def configure(c)
    super
    c.model = Book
    c.attributes = [:author__name, :title] # do not modify
    c.store_config = {sorters: {property: :id}}
    c.editing = :both
  end
end
