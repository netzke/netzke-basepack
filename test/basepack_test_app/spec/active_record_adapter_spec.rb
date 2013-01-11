require 'spec_helper'

describe Netzke::Basepack::DataAdapters::ActiveRecordAdapter do
  it "should return a list of model attributes" do
    adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Issue)
    adapter.attribute_names.should == %w[id title developer_id project_id status_id created_at updated_at]
  end

  it "should build a list of model attributes" do
    adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Issue)
    adapter.model_attributes.map{|a| a[:name]}.should == %w[id title developer__name project__title status__id created_at updated_at].map(&:to_sym)
  end
end
