if defined? DataMapper::Resource

class BookWithCustomPrimaryKey
  include DataMapper::Resource
  property :uid, Serial
  belongs_to :author
  property :title, String
  property :created_at, DateTime
  property :updated_at, DateTime
end

elsif defined? Sequel::Model

class BookWithCustomPrimaryKey < Sequel::Model
  set_primary_key :uid
  many_to_one :author
end

else

class BookWithCustomPrimaryKey < ActiveRecord::Base
  self.primary_key = 'uid'
  belongs_to :author
end

end
