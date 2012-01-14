if defined? DataMapper::Resource

class Role
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  has n, :users
  property :created_at, DateTime
  property :updated_at, DateTime
end

else

class Role < ActiveRecord::Base
  has_many :users
end

end
