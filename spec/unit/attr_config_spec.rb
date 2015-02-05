require 'spec_helper'

module Netzke::Basepack
  describe AttrConfig do
    it "should implement primary?" do
      adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)

      c = AttrConfig.new(:id, adapter)
      c.primary?.should eql true

      c = AttrConfig.new(:title, adapter)
      c.primary?.should eql false
    end

    attr_read_only_checks = {
      id: true,
      title: false,
      author__first_name: false,
      read_only_virtual_attr: true,
      assignable_virtual_attr: false
    }

    attr_read_only_checks.each_pair do |attr,value|
      it "should set default read_only for Book attribute #{attr} to #{value}" do
        adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)

        c = AttrConfig.new(attr, adapter)
        c.set_defaults!
        c.read_only.should == value
      end
    end
  end
end
