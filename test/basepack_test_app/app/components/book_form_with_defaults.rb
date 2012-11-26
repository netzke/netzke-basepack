class BookFormWithDefaults < Netzke::Basepack::Form
  def configure(c)
    c.record = Book.first
    super
    c.model = "Book"
  end
end
