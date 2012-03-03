class BookGridWithPersistence < BookGrid

  override_column :author__name, :included => false

  def default_config
    super.merge :persistence => true
  end
end
