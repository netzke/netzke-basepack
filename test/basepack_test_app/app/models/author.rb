if defined? DataMapper::Resource

class Author
  include DataMapper::Resource
  property :id, Serial
  property :first_name, String
  property :last_name, String
  property :created_at, DateTime
  property :updated_at, DateTime
  has n, :books
end


else

class Author < ActiveRecord::Base
  has_many :books
end

end

# ORM-agnostic bits
class Author

  # virtual attribute
  def name
    "#{last_name}, #{first_name}"
  end

  netzke_attribute :name

end
