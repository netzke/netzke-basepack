class AuthorGrid < Netzke::Basepack::GridPanel
  def default_config
    super.merge(
      :model => "Author"
    )
  end
end