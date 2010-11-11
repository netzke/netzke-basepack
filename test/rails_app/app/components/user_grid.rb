class UserGrid < Netzke::Basepack::GridPanel
  js_property :title, "Users"
  config :model => "User"#, :edit_form_config => {:items => [{:name => :first_name, :xtype => :htmleditor}]}
end
