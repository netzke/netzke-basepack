require File.dirname(__FILE__) + '/../spec_helper'

if defined? DataMapper::Resource

  User.class_eval do

    def self.role_id_gt_7
      all(:role_id.gt => 7)
    end

    def self.role_id_gt param
      all(:role_id.gt => param)
    end
  end

  describe Netzke::DataMapper::RelationExtensions do
    it "should accept different options in extend_with" do
      # Preparations
      10.times do |i|
        Factory(:user, :first_name => "First Name #{i}", :role_id => i)
      end

      # Tests

      User.all.extend_with(:role_id_gt_7).count.should == 2

      User.all.extend_with(:role_id_gt, 2).count.should == 7

      User.all.extend_with([:role_id_gt, 3]).count.should == 6

      User.all.extend_with(:role_id => 5).first.first_name.should == "First Name 5"

      User.all(:role_id.lt => 7).extend_with(lambda{ |relation| relation.all( :role_id.gt => 4)}).count.should == 2

      #Not supported in DM
      lambda { User.all.extend_with("select * from users where role_id > 6") }.should raise_error NotImplementedError
      lambda { User.all.extend_with(["role_id >= ?", 5]).count }.should raise_error NotImplementedError
    end
  end

elsif defined? Sequel::Model

  User.class_eval do

    def self.role_id_gt_7
      all(:role_id.gt => 7)
    end

    def self.role_id_gt param
      all(:role_id.gt => param)
    end
  end

  describe Netzke::Sequel::RelationExtensions do
    it "should accept different options in extend_with" do
      # Preparations
      10.times do |i|
        Factory(:user, :first_name => "First Name #{i}", :role_id => i)
      end

      # Tests

      User.all.extend_with(:role_id_gt_7).count.should == 2

      User.all.extend_with(:role_id_gt, 2).count.should == 7

      User.all.extend_with([:role_id_gt, 3]).count.should == 6

      User.all.extend_with(:role_id => 5).first.first_name.should == "First Name 5"

      User.all(:role_id.lt => 7).extend_with(lambda{ |relation| relation.all( :role_id.gt => 4)}).count.should == 2

      #Not supported in DM
      lambda { User.all.extend_with("select * from users where role_id > 6") }.should raise_error NotImplementedError
      lambda { User.all.extend_with(["role_id >= ?", 5]).count }.should raise_error NotImplementedError
    end
  end

else

  User.class_eval do
    scope :role_id_gt_7, where("role_id > 7")
    scope :role_id_gt, lambda { |param| where("role_id > ?", param) }
  end

  describe  Netzke::ActiveRecord::RelationExtensions do
    it "should accept different options in extend_with" do
      # Preparations
      10.times do |i|
        Factory(:user, :first_name => "First Name #{i}", :role_id => i)
      end

      # Tests
      User.where({}).extend_with(["role_id >= ?", 5]).count.should == 5

      User.where({}).extend_with(:role_id_gt_7).count.should == 2

      User.where({}).extend_with(:role_id_gt, 2).count.should == 7

      User.where({}).extend_with([:role_id_gt, 3]).count.should == 6

      User.where({}).extend_with(:role_id => 5).first.first_name.should == "First Name 5"

      User.where(["role_id < ?", 7]).extend_with(lambda{ |relation| relation.where(["role_id > ?", 4]) }).count.should == 2

      #User.where({}).extend_with("select * from users where role_id > 6").all.size.should == 3

    end
  end


end


  #it "should be extendable with extend_with_netzke_conditions" do
    ## Preparations
    #roles = [Factory(:role, :name => "admin"), Factory(:role, :name => "user"), Factory(:role, :name => "superadmin")]

    ## 3 users of each role
    #9.times do |i|
      #Factory(:user, :role_id => roles[i%3].id)
    #end

    ## Tests
    ## User.where({}).extend_with_netzke_conditions(:role_id__eq => roles.last.id).count.should == 3
    ## User.where({}).extend_with_netzke_conditions(:role_name__eq => "admin").count.should == 3
    ## User.where({}).extend_with_netzke_conditions(:role__name__like => "%admin%").count.should == 6
  #end

