require File.dirname(__FILE__) + '/../spec_helper'

describe Netzke::ActiveRecord::RelationExtensions do
  it "should accept different options in extend_with" do
    # Preparations
    10.times do |i|
      Factory(:user, :first_name => "First Name #{i}", :role_id => i)
    end

    User.scope(:role_id_gt_7, User.where(["role_id > ?", 7]))
    User.scope(:role_id_gt, lambda{ |param| User.where(["role_id > ?", param]) })

    # Tests
    User.where({}).extend_with(["role_id >= ?", 5]).count.should == 5

    User.where({}).extend_with(:role_id_gt_7).count.should == 2

    User.where({}).extend_with(:role_id_gt, 2).count.should == 7

    User.where({}).extend_with([:role_id_gt, 3]).count.should == 6

    User.where({}).extend_with(:role_id => 5).first.first_name.should == "First Name 5"

    User.where(["role_id < ?", 7]).extend_with(lambda{ |relation| relation.where(["role_id > ?", 4]) }).count.should == 2

    # User.where({}).extend_with("select * from users where role_id > 6").all.size.should == 3

  end

  it "should be extendable with extend_with_netzke_conditions" do
    # Preparations
    roles = [Factory(:role, :name => "admin"), Factory(:role, :name => "user"), Factory(:role, :name => "superadmin")]

    # 3 users of each role
    9.times do |i|
      Factory(:user, :role_id => roles[i%3].id)
    end

    # Tests
    User.where({}).extend_with_netzke_conditions(:role_id__eq => roles.last.id).count.should == 3
    User.where({}).extend_with_netzke_conditions(:role__name__eq => "admin").count.should == 3
    User.where({}).extend_with_netzke_conditions(:role__name__like => "%admin%").count.should == 6
  end
end