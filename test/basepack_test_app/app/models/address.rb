if defined? DataMapper::Resource

class Address
  include DataMapper::Resource
  property :id, Serial
  belongs_to :user
  property :street, String
  property :city, String
  property :postcode, String
  property :created_at, DateTime
  property :updated_at, DateTime
end

elsif defined? Sequel::Model

class Address < Sequel::Model
  # although this is one_to_one, according to Sequel docs,
  # the model containing the foreign key should have many_to_one
  # and the other model should have one_to_one
  many_to_one :user
end

else

class Address < ActiveRecord::Base
  belongs_to :user
end

end
