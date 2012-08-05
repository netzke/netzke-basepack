class BookGridWithPersistence < BookGrid
  column :author__name do |c|
    c.excluded = true
  end

  def configure(c)
    super
    c.persistence = true
  end
end
