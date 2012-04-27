class BookGridWithExcludedColumns < Netzke::Basepack::GridPanel
  model "Book"

  column :notes do |c|
    c.excluded = true
  end

  column :exemplars do |c|
    c.excluded = true
  end
end
