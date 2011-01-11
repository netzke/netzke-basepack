require File.dirname(__FILE__) + '/../spec_helper'

describe Netzke::ActiveRecord::Attributes do
  it "should return Netzke attributes in natural order" do
    User.send(:netzke_attrs_in_natural_order).map{ |a| a[:name] }.should == %w(id first_name last_name role__name created_at updated_at)
  end

  it "should return exposed Netzke attributes" do
    class UserExt < User
      netzke_expose_attributes :first_name, :created_at
    end
    UserExt.netzke_attributes.map{ |a| a[:name] }.should == %w(id first_name created_at)
  end

  it "should return Netzke attributes including an association attribute represented by a virtual method" do
    p Book.netzke_attributes.map{ |a| a[:name] }
    p %w(id author__name title exemplars digitized notes created_at updated_at tags rating)
    Book.netzke_attributes.map{ |a| a[:name] }.sort!.should == %w(id author__name title exemplars digitized notes created_at updated_at tags rating).sort!
    Book.netzke_attributes.detect{ |a| a[:name] == "author__name" }[:attr_type].should == :string
  end

  it "should be possible to read author name via a book using association attribute" do
    author = Factory(:author)
    book = Factory(:book, :author => author)
    book.value_for_attribute({:name => :author__first_name}).should == "Carlos"
  end

  it "should be possible to assign author's name via a book using association attribute" do
    author = Factory(:author)
    book = Factory(:book, :author => author)
    book.set_value_for_attribute({:name => :author__first_name, :nested_attribute => true}, "Carlitos")
    author.first_name.should == "Carlitos"
  end

  it "should be possible to change author for a book using association attribute" do
    author_carlos = Factory(:author, :first_name => "Carlos")
    author_herman = Factory(:author, :first_name => "Herman")
    book = Factory(:book, :author => author_carlos)
    book.set_value_for_attribute({:name => :author__first_name}, "Herman")
    book.author.should == author_herman
  end

  it "should be possible to change address of a user via association attribute (without specifying :nested_attribute)" do
    address = Factory(:address)
    user = Factory(:user, :address => address)
    user.set_value_for_attribute({:name => :address__city}, "Hidden Treasures")
    address.city.should == "Hidden Treasures"
  end

end
