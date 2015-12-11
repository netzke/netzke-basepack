class Grid::MetaColumn < Netzke::Basepack::Grid
  column :meta_attribute do |c|
    c.meta = true
    c.getter = ->(r) { "Exemplars: #{r.exemplars}" }
  end

  action :show_first, :show_second

  def configure(c)
    super
    c.model = Book
    c.columns = [:title, :meta_attribute]
  end

  def bbar
    [*super, :show_first, :show_second]
  end
end
