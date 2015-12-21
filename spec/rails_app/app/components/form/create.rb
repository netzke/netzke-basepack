class Form::Create < Netzke::Form::Base
  def configure(c)
    super
    c.model = "Book"
  end
end
