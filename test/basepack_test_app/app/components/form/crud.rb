class Form::Crud < Netzke::Basepack::Form
  def configure(c)
    super
    c.model = "Book"
  end
end
