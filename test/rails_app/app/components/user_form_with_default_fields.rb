class UserFormWithDefaultFields < Netzke::Basepack::FormPanel
  config do
    {
      :model => 'User',
      :record_id => User.first.id
    }
  end
end
