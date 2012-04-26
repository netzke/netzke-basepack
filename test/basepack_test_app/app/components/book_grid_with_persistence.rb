class BookGridWithPersistence < BookGrid
  #override_column :author__name, :included => false
  column :author__name do |c|
    c.included = false
  end

  def configure
    super
    config.persistence = true
  end

  def columns
    [:title, :exemplars, :digitized]
  end
end
