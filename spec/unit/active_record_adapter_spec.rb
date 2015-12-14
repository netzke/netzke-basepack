require 'spec_helper'

describe Netzke::Basepack::DataAdapters::ActiveRecordAdapter do
  it "should return a list of model attributes" do
    adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)
    adapter.attribute_names.should == %w[id title author_id exemplars digitized notes published_on last_read_at tags rating price created_at updated_at]
  end

  it "should build a list of model attributes" do
    adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)
    adapter.model_attributes.should == %w[id title author__name exemplars digitized notes published_on last_read_at tags rating price created_at updated_at].map(&:to_sym)
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

  describe "#combo_data" do
    it "returns scoped compo data if association scope is set" do
      3.times {FactoryGirl.create(:author)}
      adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)

      attr = {
        name: "author__first_name",
        scope: ->(r) {r.limit(2)}
      }

      expect(adapter.combo_data(attr).size).to eql 2
    end
  end
end
