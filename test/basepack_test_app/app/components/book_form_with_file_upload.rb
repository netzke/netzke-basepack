class BookFormWithFileUpload < Netzke::Basepack::FormPanel
  model "Book"

  def configure(c)
    super
    c.record = Book.first
    c.file_upload = true
  end

  # This should be supported by the model, e.g. using Carrierwave
  def items
    [{name: :attachment, xtype: :fileuploadfield}, *super]
  end
end
