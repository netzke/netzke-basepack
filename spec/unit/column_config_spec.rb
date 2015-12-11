require 'spec_helper'

module Netzke::Basepack
  describe ColumnConfig do
    it "not set default editor for read-only columns" do
      adapter = Netzke::Basepack::DataAdapters::ActiveRecordAdapter.new(Book)
      c = ColumnConfig.new(:title, adapter)
      c.read_only = true
      c.set_defaults

      expect(c.editor).to be_nil
    end
  end
end
