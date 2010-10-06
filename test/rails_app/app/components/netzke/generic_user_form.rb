module Netzke
  class GenericUserForm < Basepack::FormPanel
    def config
      {
        :model => 'Forms::GenericUser',
        :title => 'Users',
        :record_id => User.first.id
      }.deep_merge super
    end
    
  end
end