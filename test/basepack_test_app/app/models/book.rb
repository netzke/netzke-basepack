class Book < ActiveRecord::Base
  attr_accessible :title, :exemplars, :digitized, :notes, :tags, :rating, :author_id, :last_read_at, :published_on, :cover
  belongs_to :author
  validates :title, presence: true

  mount_uploader :cover

  scope :sorted_by_author_name, lambda { |dir| joins(:author).order("authors.first_name #{dir}, authors.last_name #{dir}") }

  attr_protected :exemplars, :author_id, :as => :user

  def read_only_virtual_attr
    "Dummy value"
  end

  def assignable_virtual_attr=(value)
  end
end
