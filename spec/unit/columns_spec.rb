require 'spec_helper'

module Netzke::Basepack
  describe Columns do
    it "provides correct list of default fields for forms" do
      fields = ::Grid::CustomColumns.new.send :default_fields_for_forms
      fields.map{|f| f[:name]}.should == %w[id author__first_name author__last_name author__name title digitized rating exemplars updated_at]
    end

    it "provides correct read_only configs for default fields for forms" do
      fields = ::Grid::CustomColumns.new.send :default_fields_for_forms
      fields.map{|f| f[:read_only]}.should == [true, true, true, false, false, false, false, false, false]
    end

    it "should allow overriding columns" do
      class TheGrid < Netzke::Basepack::Grid
        model "Book"
        column :title do |c|
          c.renderer = "uppercase"
        end
      end

      columns = TheGrid.new.js_columns
      columns.detect{|c| c[:name] == 'title'}[:renderer].should == 'uppercase'
    end

    it 'makes virtual attributes not editable and not sortable by default' do
      class TheGrid < Netzke::Basepack::Grid
        model "Book"
        column :in_abundance do |c|
          c.getter = ->{ true }
        end
      end
      column = TheGrid.new.js_columns.detect{|c| c[:name] == 'in_abundance'}
      column[:read_only].should eql true
      column[:sortable].should eql false
    end

    it 'does not render excluded columns' do
      class TheGrid < Netzke::Basepack::Grid
        model "Book"

        column :exemplars do |c|
          c.excluded = true
        end
      end

      TheGrid.new.js_columns.detect{|c| c[:name] == 'exemplars'}.should be_nil
    end
  end
end
