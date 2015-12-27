class Form::Multiedit < Netzke::Form::Base
  def configure(c)
    super
    c.model = Book
    c.record = Book.first
  end
end
