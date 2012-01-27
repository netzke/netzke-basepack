if defined? DataMapper::Resource

class Book
  include DataMapper::Resource
  property :id, Serial
  belongs_to :author, :required => false
  validates_presence_of :title, :message => "Title can't be blank"
  property :title, String
  property :exemplars, Integer
  property :digitized, Boolean
  property :notes, Text
  property :tags, String
  property :rating, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
  property :last_read_at, DateTime
  property :published_on, Date

  def self.sorted_by_author_name dir
    Book.all :order => [(Book.author.last_name.send dir),(Book.author.first_name.send dir)]
  end

end

else

class Book < ActiveRecord::Base
  belongs_to :author
  validates_presence_of :title

  scope :sorted_by_author_name, lambda { |dir| joins(:author).order("authors.last_name #{dir}, authors.first_name #{dir}") }
end

end
