module Forms
  class GenericUser < User
    netzke_attribute :first_name, :xtype => "combo", :store => ["Paul", "Max"]
    netzke_expose_attributes :id, :first_name, :last_name
  end
end