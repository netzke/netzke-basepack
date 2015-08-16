class BookFormWithFileUpload < Netzke::Basepack::Form
  def configure(c)
    super
    c.model = "Book"
  end

  def items
    [{name: 'cover', xtype: :filefield}, *super]
  end
end
