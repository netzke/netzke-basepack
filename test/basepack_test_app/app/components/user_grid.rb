class UserGrid < Netzke::Basepack::GridPanel
  def configure(c)
    c.model = "User"
    c.title = "Users"
    super
  end

  add_form_config :class_name => "UserForm"
  edit_form_config :class_name => "UserForm"
  multi_edit_form_config :class_name => "UserForm"
end
