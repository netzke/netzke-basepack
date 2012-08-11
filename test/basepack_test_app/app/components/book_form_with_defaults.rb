class BookFormWithDefaults < Netzke::Basepack::FormPanel
  def configure(c)
    c.model = "Book"
    c.record = Book.first
    super
  end
end
