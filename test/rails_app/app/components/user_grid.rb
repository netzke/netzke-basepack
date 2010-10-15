class UserGrid < Netzke::Basepack::GridPanel

  def config
    {
      :mode => :config,
      :model => "User",
      :title => "Users"
    }.deep_merge super
  end

end
