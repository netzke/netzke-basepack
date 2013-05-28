class BookFormWithFileUpload < Netzke::Basepack::Form
  def configure(c)
    super
    c.model = "Book"
  end

  def items
    [{name: 'cover', xtype: :filefield}, *super]
  end

  endpoint :netzke_submit do |params, this|
    super params, this

    # record will be updated, with the attachments
  end
end
