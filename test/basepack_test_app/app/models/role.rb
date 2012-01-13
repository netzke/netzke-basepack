case (ENV['ORM'] || '').downcase
when 'dm'

class Role

end

else

class Role < ActiveRecord::Base
  has_many :users
end

end
