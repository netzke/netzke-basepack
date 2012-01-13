case (ENV['ORM'] || '').downcase
when 'dm'

class Author
  include DataMapper::Resource
  property :id, Serial
end


else

class Author < ActiveRecord::Base
  has_many :books

  # virtual attribute
  def name
    "#{last_name}, #{first_name}"
  end

  netzke_attribute :name
end

end
