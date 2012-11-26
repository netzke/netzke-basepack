class UserFormWithDefaultFields < Netzke::Basepack::Form
  def configure(c)
    c.model = "User"
    c.record = User.first
    super
  end
end
