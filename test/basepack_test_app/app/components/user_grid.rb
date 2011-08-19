class UserGrid < Netzke::Basepack::GridPanel
  js_property :title, "Users"
  def configuration
    super.merge(
      :model => "User"
      # :columns => [:first_name, {:name => :address__city}]
      # :edit_form_config => {:items => [{:name => :first_name, :xtype => :htmleditor}]}
    )
  end
end
