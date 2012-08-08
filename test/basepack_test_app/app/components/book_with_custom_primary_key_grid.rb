class BookWithCustomPrimaryKeyGrid < Netzke::Basepack::GridPanel

  def configure(c)
    super
    c.title = "Books (model with non-standard id)"
    c.model = "BookWithCustomPrimaryKey"
  end

end
