class UserFormWithDefaultFields < Netzke::Basepack::FormPanel
  def configure!
    super
    @config.merge!(
      :model => 'User',
      :record_id => User.first.id
    )
  end
end
