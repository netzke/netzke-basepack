class BookFormWithFileUpload < Netzke::Basepack::FormPanel
  model "Book"

  def configure
    super
    config.record = Book.first
    config.file_upload= true
  end

  # This should be supported by the model, e.g. using Carrierwave
  def items
    [{name: :attachment, xtype: :fileuploadfield}, *super]
  end
end
