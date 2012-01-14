if defined? DataMapper::Resource

class BookWithCustomPrimaryKey
  include DataMapper::Resource
  property :uid, Serial
  belongs_to :author
  property :title, String
  property :created_at, DateTime
  property :updated_at, DateTime
end

else

class BookWithCustomPrimaryKey < ActiveRecord::Base
  set_primary_key 'uid'
  belongs_to :author
end

end
