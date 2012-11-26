class BookGridWithExcludedColumns < Netzke::Basepack::Grid
  model "Book"

  column :notes do |c|
    c.excluded = true
  end

  column :exemplars do |c|
    c.excluded = true
  end
end
