class BookFormWithDefaults < Netzke::Basepack::FormPanel
  def configure(c)
    super
    c.model = "Book"
    c.record_id = Book.first.id
  end
end
