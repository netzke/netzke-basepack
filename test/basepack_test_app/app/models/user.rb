if defined? DataMapper::Resource

class User
  include DataMapper::Resource
  property :id, Serial
end

else

class User < ActiveRecord::Base
  # scope :latest, lambda {|param| where(:created_at.gt => param)}
  belongs_to :role
  has_one :address
end

end
