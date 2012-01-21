require File.dirname(__FILE__) + '/../spec_helper'

describe Netzke::Basepack::DataAdapters::AbstractAdapter.adapter_class(Book) do
  it "should return a hash fk to model" do
    adapter = Netzke::Basepack::DataAdapters::AbstractAdapter.adapter_class(Book).new(Book)
    adapter.hash_fk_model.should == {:author_id => :author}
  end


end
