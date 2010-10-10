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
end