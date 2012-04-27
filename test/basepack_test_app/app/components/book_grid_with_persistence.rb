class BookGridWithPersistence < BookGrid
  column :author__name do |c|
    c.excluded = true
  end

  def configure
    super
    config.persistence = true
  end
end
