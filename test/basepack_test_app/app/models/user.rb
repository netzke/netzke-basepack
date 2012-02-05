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

elsif defined? Sequel::Model

class User < Sequel::Model
  many_to_one :role
  one_to_one :address
end

else

class User < ActiveRecord::Base
  # scope :latest, lambda {|param| where(:created_at.gt => param)}
  belongs_to :role
  has_one :address
end

end
