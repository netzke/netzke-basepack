if 'ar' == ENV["ORM"].downcase
class Address < ActiveRecord::Base
  belongs_to :user
end
end
