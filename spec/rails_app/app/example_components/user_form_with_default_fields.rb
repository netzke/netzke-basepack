class UserFormWithDefaultFields < Netzke::Form::Base
  def configure(c)
    c.model = "User"
    c.record = User.first
    super
  end
end
