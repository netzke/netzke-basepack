require 'spec_helper'

module Netzke::Basepack
  describe Columns do
    it "should provide correct list of default fields for forms" do
      fields = ::Grid::CustomColumns.new.send :default_fields_for_forms
      fields.map{|f| f[:name]}.should == %w[id author__first_name author__last_name author__name title digitized rating exemplars updated_at]
    end

    it "should provide correct read_only configs for default fields for forms" do
      fields = ::Grid::CustomColumns.new.send :default_fields_for_forms
      fields.map{|f| f[:read_only]}.should == [true, true, true, false, false, false, false, false, false]
    end
  end
end
