class UserFormWithDefaultFields < Netzke::Basepack::FormPanel
  def configure(c)
    c.model = "User"
    c.record = User.first
    super
  end
end
