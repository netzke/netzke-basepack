class BookFormWithDefaults < Netzke::Form::Base
  def configure(c)
    c.record = Book.first
    super
    c.model = "Book"
  end
end
