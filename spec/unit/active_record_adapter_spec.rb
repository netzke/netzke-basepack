require 'spec_helper'

describe Netzke::Basepack::DataAdapters::ActiveRecordAdapter do
  it "returns list of model attributes" do
    adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)
    expect(adapter.attribute_names).to eql %w[id title author_id exemplars digitized notes published_on last_read_at tags rating price created_at updated_at]
  end

  it "builds list of model attribute names" do
    adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)
    expect(adapter.model_attributes).to eql %w[id title author__name exemplars digitized notes published_on last_read_at tags rating price created_at updated_at].map(&:to_sym)
  end

  it "detects virtual attributes" do
    adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)
    expect(adapter.virtual_attribute?({name: 'author__first_name'})).to eql false
    expect(adapter.virtual_attribute?({name: 'title'})).to eql false
    expect(adapter.virtual_attribute?({name: 'author__name'})).to eql true
    expect(adapter.virtual_attribute?({name: 'read_only_virtual_attr'})).to eql true
  end

  describe '#record_value_for_attribute' do
    it 'returns nil for attribute with name "some_assoc__id" if the association is nil' do
      adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)
      book = Book.create(title: 'Foo')
      expect(adapter.record_value_for_attribute(book, {name: 'author__id'}, true)).to be_nil
    end

    it "returns html-escaped value if escape_html option is true" do
      adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)
      book = Book.create(title: '<b>Foo</b>')
      expect(adapter.record_value_for_attribute(book, {name: 'title'})).to eql "&lt;b&gt;Foo&lt;/b&gt;"
    end
  end

  describe "#combo_data" do
    it "returns scoped compo data if association scope is set" do
      3.times {FactoryGirl.create(:author)}
      adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)

      attr = {
        name: "author__first_name",
        scope: lambda {|r| r.limit(2)}
      }

      expect(adapter.combo_data(attr).size).to eql 2
    end
  end

  describe "#get_records" do
    it "makes use of Proc scope" do
      FactoryGirl.create(:author, first_name: "Kate")
      FactoryGirl.create(:author, first_name: "Kate")
      FactoryGirl.create(:author, first_name: "Jane")

      adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Author)

      params = {
        scope: lambda {|rel| rel.where(first_name: "Kate")}
      }

      expect(adapter.get_records(params).size).to eql 2
    end

    it "makes use of Hash scope" do
      FactoryGirl.create(:author, first_name: "Kate")
      FactoryGirl.create(:author, first_name: "Kate")
      FactoryGirl.create(:author, first_name: "Jane")

      adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Author)

      params = {
        scope: {first_name: "Kate"}
      }

      expect(adapter.get_records(params).size).to eql 2
    end
  end
end
