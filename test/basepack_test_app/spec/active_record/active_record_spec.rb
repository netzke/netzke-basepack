if !defined? DataMapper::Resource

require File.dirname(__FILE__) + '/../spec_helper'

describe Netzke::Basepack::DataAdapters::ActiveRecordAdapter do
  it "should return a hash fk to model" do
    adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)
    adapter.hash_fk_model.should == {:author_id => :author}
  end


end

end
