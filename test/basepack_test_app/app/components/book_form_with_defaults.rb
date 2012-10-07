class BookFormWithDefaults < Netzke::Basepack::FormPanel
  def configure(c)
    c.record = Book.first
    super
    c.model = "Book"
  end
end
