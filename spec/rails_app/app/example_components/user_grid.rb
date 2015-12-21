class UserGrid < Netzke::Grid::Base
  def configure(c)
    c.model = "User"
    c.title = "Users"
    super
  end

  # The way to make the grid use a custom form
  def configure_form_window(c)
    super
    c.form_config.klass = UserForm
  end
end
