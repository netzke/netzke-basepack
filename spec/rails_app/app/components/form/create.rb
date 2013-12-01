class Form::Create < Netzke::Basepack::Form
  def configure(c)
    super
    c.model = "Book"
  end
end
