require File.dirname(__FILE__) + '/../spec_helper'

describe Netzke::Basepack::FormPanel do
  it "should have correct fields" do
    form = Netzke::Basepack::FormPanel.new(:model => 'User')
    form.fields_from_model.keys.map(&:to_s).sort.should == %w(created_at first_name id last_name role__name updated_at)
  end
  
  it "should extract fields from config" do
    form = Netzke::Basepack::FormPanel.new(:model => 'User', :items => [{:xtype => 'fieldset', :items => [:first_name, {:name => "last_name"}]}, :created_at, {:name => :updated_at}])
    
    form.fields_from_config.keys.map(&:to_s).sort.should == %w(created_at first_name id last_name updated_at)
  end
  
  it "should set correct xtype for columns" do
    form = Netzke::Basepack::FormPanel.new(:model => 'User', :items => [:first_name, :created_at, :role__name])
    
    form.fields[:first_name][:xtype].should == :textfield
    form.fields[:created_at][:xtype].should == :xdatetime
    form.fields[:role__name][:xtype].should == :combobox
  end
  
  it "should set correct default field labels" do
    form = Netzke::Basepack::FormPanel.new(:model => 'User', :items => [:first_name, :created_at, :role__name])
    
    form.fields[:first_name][:field_label].should == "First name"
    form.fields[:created_at][:field_label].should == "Created at"
    form.fields[:role__name][:field_label].should == "Role name"
  end
  
  it "should set correct field values" do
    role = Factory(:role, :name => "warrior")
    user = Factory(:user, :first_name => "Carlos", :last_name => "Castaneda", :role => role)
    
    form = Netzke::Basepack::FormPanel.new(:model => 'User', :record => user, :items => [:first_name, :last_name, :role__name])
    
    form.fields[:first_name][:value].should == "Carlos"
    form.fields[:last_name][:value].should == "Castaneda"
    form.fields[:role__name][:value].should == "warrior"
  end
  
  it "should add primary key field automatically when omitted" do
    form = Netzke::Basepack::FormPanel.new(:model => 'User', :items => [:first_name, :last_name, :role__name])
    form.fields[:id].should_not be_nil
  end
  
  it "should pass normalized items to JS" do
    form = Netzke::Basepack::FormPanel.new(:model => 'User', :items => [
      {:xtype => 'fieldset', :items => [
        :first_name, 
        {:name => "last_name"}
      ]},
      :created_at,
      {:name => :updated_at}
    ])

    form.items[0][:name].should == "id"
    form.items[1][:items][0][:name].should == "first_name"
    form.items[1][:items][1][:name].should == "last_name"
    form.items[2][:name].should == "created_at"
    form.items[3][:name].should == "updated_at"
  end
  
end