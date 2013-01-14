class Book < ActiveRecord::Base
  belongs_to :author
  validates_presence_of :title

  scope :sorted_by_author_name, lambda { |dir| joins(:author).order("authors.last_name #{dir}, authors.first_name #{dir}") }

  attr_protected :exemplars, :author_id, :as => :user

  def some_virtual_attr
    "Dummy result"
  end
end
