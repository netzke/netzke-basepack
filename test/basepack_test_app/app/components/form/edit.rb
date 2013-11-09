class Form::Edit < Netzke::Basepack::Form
  def configure(c)
    super
    c.model = "Book"
    c.record = Book.first
  end
end
