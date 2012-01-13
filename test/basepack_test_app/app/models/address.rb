case ENV["ORM"].downcase
when 'dm'
class Address
  include DataMapper::Resource
end
else
class Address < ActiveRecord::Base
  belongs_to :user
end
end
