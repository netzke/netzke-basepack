class BookGridWithPersistence < BookGrid
  column :author__name do |c|
    c.excluded = true
  end

  def configure(c)
    c.persistence = true
    super
  end
end
