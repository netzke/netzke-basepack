class BookWithCustomPrimaryKey < ActiveRecord::Base
  self.primary_key = 'uid'
  belongs_to :author
end
