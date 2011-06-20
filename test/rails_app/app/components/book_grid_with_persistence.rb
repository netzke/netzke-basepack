class BookGridWithPersistence < BookGrid

  def default_config
    super.merge :persistence => true
  end
end
