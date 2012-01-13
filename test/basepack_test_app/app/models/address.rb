case (ENV['ORM'] || '').downcase
when 'dm'
class Address
  include DataMapper::Resource
  property :id, Serial
  belongs_to :user
  property :street, String
  property :city, String
  property :postcode, String
  has 1, :country
  property :created_at, DateTime
  property :updated_at, DateTime
end
else
class Address < ActiveRecord::Base
  belongs_to :user
end
end
