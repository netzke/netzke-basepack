require 'spec_helper'

describe Netzke::Basepack::DataAdapters::ActiveRecordAdapter do
  it "should return a list of model attributes" do
    adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Issue)
    adapter.attribute_names.should == %w[id title developer_id project_id status_id created_at updated_at]
  end

  it "should build a list of model attributes" do
    adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Issue)
    adapter.model_attributes.should == %w[id title developer__name project__title status__id created_at updated_at].map(&:to_sym)
  end

  it "should detect virtual attributes" do
    adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)
    adapter.virtual_attribute?({name: 'author__first_name'}).should be_false
    adapter.virtual_attribute?({name: 'title'}).should be_false
    adapter.virtual_attribute?({name: 'author__name'}).should be_true
    adapter.virtual_attribute?({name: 'read_only_virtual_attr'}).should be_true
  end
end
