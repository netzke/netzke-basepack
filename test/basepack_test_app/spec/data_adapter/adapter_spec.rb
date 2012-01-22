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
    castaneda = Factory(:author, {:first_name => "Carlos", :last_name => "Castaneda"})
    hesse = Factory(:author, {:first_name => "Herman", :last_name => "Hesse"})

    Factory(:book, {:title => "Journey to Ixtlan", :author => castaneda})
    Factory(:book, {:title => "The Tales of Power", :author => castaneda})
    Factory(:book, {:title => "The Art of Dreaming", :author => castaneda})
    Factory(:book, {:title => "Steppenwolf", :author => hesse})
    Factory(:book, {:title => "Demian", :author => hesse})
    Factory(:book, {:title => "Narciss and Goldmund", :author => hesse})

    @adapter = Netzke::Basepack::DataAdapters::AbstractAdapter.adapter_class(Book).new(Book)
  end

  it "should return a hash fk to model" do
    @adapter.hash_fk_model.should == {:author_id => :author}
  end

  # TODO: test scope and query for assoc columns and non-assoc columns

end
