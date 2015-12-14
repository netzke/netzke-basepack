class BookGridWithExcludedColumns < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = Book
    c.default_filters = [{column: :last_read_at, value: {after: Date.parse("2011-01-01")}}]
  end

  column :notes do |c|
    c.excluded = true
  end

  column :exemplars do |c|
    c.excluded = true
  end
end
