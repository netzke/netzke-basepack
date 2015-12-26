require 'spec_helper'

module Netzke::Basepack
  describe AttrConfig do
    it "implements primary?" do
      adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)

      c = AttrConfig.new(:id, adapter)
      expect(c.primary?).to eql true

      c = AttrConfig.new(:title, adapter)
      expect(c.primary?).to eql false
    end

    attr_read_only_checks = {
      id: true,
      title: nil,
      author__first_name: nil,
      read_only_virtual_attr: true,
      assignable_virtual_attr: nil
    }

    attr_read_only_checks.each_pair do |attr,value|
      it "sets default read_only for Book attribute #{attr} to #{value}" do
        adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)

        c = AttrConfig.new(attr, adapter)
        c.set_defaults
        expect(c.read_only).to eql value
      end
    end
  end
end
