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
    all :order => [ author.last_name.send(dir), author.first_name.send(dir) ], :links => [ relationships[:author].inverse ]
  end

end

elsif defined? Sequel::Model

class Book < Sequel::Model
  many_to_one :author

  def_dataset_method(:sorted_by_author_name) do |dir|
    eager_graph(:author).order_append(:author__last_name.send(dir), :author__first_name.send(dir))
  end

  def validate
    validates_presence :title, :message => "can't be blank"
  end

end

else

class Book < ActiveRecord::Base
  belongs_to :author
  validates_presence_of :title

  scope :sorted_by_author_name, lambda { |dir| joins(:author).order("authors.last_name #{dir}, authors.first_name #{dir}") }
end

end
