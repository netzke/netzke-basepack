class Grid::DefaultValues < Netzke::Grid::Base
  def model
    Book
  end

  def columns
    [ :title, :author__last_name, :exemplars, :digitized ]
  end

  column :title do |c|
    c.default_value = "Lolita"
  end

  column :author__last_name do |c|
    c.default_value = Author.first.id
  end

  column :exemplars do |c|
    c.default_value = 100
  end

  column :digitized do |c|
    c.default_value = true
  end
end
