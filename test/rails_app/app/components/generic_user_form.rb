class GenericUserForm < Netzke::Basepack::FormPanel
  
  config do
    {
      :model => 'User',
      :title => 'Users',
      :record_id => User.first.id,
      :items => [:id, :first_name]
    }
  end
  
end