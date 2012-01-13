case (ENV['ORM'] || '').downcase
when 'dm'

class Role
  include DataMapper::Resource
  property :id, Serial
end

else

class Role < ActiveRecord::Base
  has_many :users
end

end
