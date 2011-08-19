class BookWithCustomPrimaryKeyGrid < Netzke::Basepack::GridPanel

  js_property :title, "Books (model with non-standard id)"

  def default_config
    super.merge(
      :model => "BookWithCustomPrimaryKey"
    )
  end
end
