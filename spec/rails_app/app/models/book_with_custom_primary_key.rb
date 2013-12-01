class BookWithCustomPrimaryKey < ActiveRecord::Base
  attr_accessible :title, :author_id
  self.primary_key = 'uid'
  belongs_to :author
end
