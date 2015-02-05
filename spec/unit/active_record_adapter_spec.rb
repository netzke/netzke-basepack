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
    adapter.virtual_attribute?({name: 'author__first_name'}).should eql false
    adapter.virtual_attribute?({name: 'title'}).should eql false
    adapter.virtual_attribute?({name: 'author__name'}).should eql true
    adapter.virtual_attribute?({name: 'read_only_virtual_attr'}).should eql true
  end

  describe '#record_value_for_attribute' do
    it 'returns nil for attribute with name "some_assoc__id" if the association is nil' do
      adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)
      book = Book.create(title: 'Foo')
      adapter.record_value_for_attribute(book, {name: 'author__id'}, true).should be_nil
    end
  end
end
