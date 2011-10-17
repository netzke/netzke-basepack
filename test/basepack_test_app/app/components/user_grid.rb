class UserGrid < Netzke::Basepack::GridPanel
  title "Users"
  model "User"

  add_form_config :class_name => "UserForm"
  edit_form_config :class_name => "UserForm"
end
