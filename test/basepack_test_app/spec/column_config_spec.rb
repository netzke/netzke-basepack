require 'spec_helper'

module Netzke::Basepack
  describe ColumnConfig do
    it "should respond to primary?" do
      adapter = BookGrid.new.data_adapter

      c = ColumnConfig.new(:id, adapter)
      c.primary?.should be_true

      c = ColumnConfig.new(:title, adapter)
      c.primary?.should be_false
    end
  end
end
