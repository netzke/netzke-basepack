case (ENV['ORM'] || '').downcase
when 'dm'

class BookWithCustomPrimaryKey

end

else

class BookWithCustomPrimaryKey < ActiveRecord::Base
  set_primary_key 'uid'
  belongs_to :author
end

end
