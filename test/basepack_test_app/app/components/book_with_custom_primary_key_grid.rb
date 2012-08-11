class BookWithCustomPrimaryKeyGrid < Netzke::Basepack::GridPanel

  def configure(c)
    c.title = "Books (model with non-standard id)"
    c.model = "BookWithCustomPrimaryKey"
    super
  end

end
