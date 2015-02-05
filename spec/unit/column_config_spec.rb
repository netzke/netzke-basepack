require 'spec_helper'

module Netzke::Basepack
  describe ColumnConfig do
    it "should implement primary?" do
      adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)

      c = ColumnConfig.new(:id, adapter)
      c.primary?.should eql true

      c = ColumnConfig.new(:title, adapter)
      c.primary?.should eql false
    end

    it "should not set default editor for read-only columns" do
      adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)
      c = ColumnConfig.new(:title, adapter)
      c.read_only = true
      c.set_defaults!

      c.editor.should be_nil
    end
  end
end
