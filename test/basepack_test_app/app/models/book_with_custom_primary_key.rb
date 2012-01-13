case (ENV['ORM'] || '').downcase
when 'dm'

class BookWithCustomPrimaryKey
  include DataMapper::Resource
  property :id, Serial
end

else

class BookWithCustomPrimaryKey < ActiveRecord::Base
  set_primary_key 'uid'
  belongs_to :author
end

end
