if defined? DataMapper::Resource

class User
  include DataMapper::Resource
  property :id, Serial
  property :first_name, String
  property :last_name, String
  belongs_to :role, :required => false
  has 1, :address
  property :created_at, DateTime
  property :updated_at, DateTime
end

else

class User < ActiveRecord::Base
  # scope :latest, lambda {|param| where(:created_at.gt => param)}
  belongs_to :role
  has_one :address
end

end
