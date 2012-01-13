if 'dm' == ENV["ORM"].downcase
  class Address
    include DataMapper::Resource
  end
end
