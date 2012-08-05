class UserFormWithDefaultFields < Netzke::Basepack::FormPanel
  def configure(c)
    super
    c.merge!(
      :model => 'User',
      :record_id => User.first.id
    )
  end
end
