class BookFormWithDefaults < Netzke::Basepack::FormPanel
  def configure
    super
    @config[:model] = "Book"
    @config[:record_id] = Book.first.id
  end
end
