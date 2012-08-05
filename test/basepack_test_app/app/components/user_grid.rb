class UserGrid < Netzke::Basepack::GridPanel
  def configure(c)
    super
    c.title = "Users"
  end

  model "User"

  add_form_config :class_name => "UserForm"
  edit_form_config :class_name => "UserForm"
  multi_edit_form_config :class_name => "UserForm"
end
