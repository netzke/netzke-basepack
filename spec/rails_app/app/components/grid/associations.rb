class Grid::Associations < Netzke::Grid::Base
  def configure(c)
    super
    c.model = 'Book'
    c.edit_inline = true
    c.columns = [:title, :author__first_name, :author__prize_count]
  end
end
