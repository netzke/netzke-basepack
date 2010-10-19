class UserGrid < Netzke::Basepack::GridPanel

  def config
    super.merge({
      :model => "User",
      :title => "Users"
    })
  end

end
