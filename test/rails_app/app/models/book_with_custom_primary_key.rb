class BookWithCustomPrimaryKey < ActiveRecord::Base
  set_primary_key 'uid'
  belongs_to :author
end
