class BookGridWithPersistence < BookGrid
  override_column :author__name, :included => false

  def configure
    super
    config.persistence = true
  end
end
