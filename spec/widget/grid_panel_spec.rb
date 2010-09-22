require File.dirname(__FILE__) + '/../spec_helper'

describe Netzke::Component::GridPanel do
  it "should have correct amount of default columns" do
    u1 = Factory(:user)
    grid = Netzke::Component::GridPanel.new(:model => 'User')
    
    grid.columns.size.should == 6
  end
end