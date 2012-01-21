require File.dirname(__FILE__) + '/../spec_helper'

if defined? DataMapper::Resource

  # DatabaseCleaner not working in transaction mode for DM
  DatabaseCleaner.strategy=:truncation
  DatabaseCleaner.clean!

  class Book

    def self.title_like_jou
      all(:title.like => "Jou%")
    end

    def self.author_name_like_he
      all(Author.last_name.like => "He%")
    end
  end

else

  class Book
    scope :title_like_jou, where("title LIKE 'Jou%'")
    scope :author_name_like_he, joins(:author).where("authors.last_name LIKE 'He%'")
  end

end


describe Netzke::Basepack::DataAdapters::AbstractAdapter.adapter_class(Book) do

  before :all do
    Author.create([
      {:first_name => "Carlos", :last_name => "Castaneda"},
      {:first_name => "Herman", :last_name => "Hesse"}
    ])

    hesse = Author.find_by_last_name("Hesse")
    castaneda = Author.find_by_last_name("Castaneda")

    Book.create([
      {:title => "Journey to Ixtlan", :author => castaneda},
      {:title => "The Tales of Power", :author => castaneda},
      {:title => "The Art of Dreaming", :author => castaneda},
      {:title => "Steppenwolf", :author => hesse},
      {:title => "Demian", :author => hesse},
      {:title => "Narciss and Goldmund", :author => hesse}
    ])

    @adapter = Netzke::Basepack::DataAdapters::AbstractAdapter.adapter_class(Book).new(Book)
  end

  it "should return a hash fk to model" do
    @adapter.hash_fk_model.should == {:author_id => :author}
  end

  # TODO: test scope and query for assoc columns and non-assoc columns

end
