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
      class GridOne < Netzke::Basepack::Grid
        def configure(c)
          super
          c.model = Book
        end

        column :title do |c|
          c.renderer = "uppercase"
          c.hidden = true
        end
      end

      columns = GridOne.new.js_columns
      columns.detect{|c| c[:name] == 'title'}[:renderer].should == 'uppercase'
    end

    it 'prepends primary key column automatically when columns are listed explicitely' do
      class GridTwo < Netzke::Basepack::Grid
        column :id do |c|
          c.hidden = false
        end

        def configure(c)
          super
          c.model = Book
          c.columns = [:title]
        end
      end

      columns = GridTwo.new.js_columns
      columns.detect{|c| c[:name] == 'id'}[:hidden].should_not == true # not hidden by default in Ext JS grid
    end

    it 'makes virtual attributes not editable and not sortable by default' do
      class GridThree < Netzke::Basepack::Grid
        def configure(c)
          super
          c.model = Book
        end

        column :in_abundance do |c|
          c.getter = ->{ true }
        end
      end
      column = GridThree.new.js_columns.detect{|c| c[:name] == 'in_abundance'}
      column[:read_only].should eql true
      column[:sortable].should eql false
    end

    it 'does not render excluded columns' do
      class GridFour < Netzke::Basepack::Grid
        def configure(c)
          super
          c.model = Book
        end

        column :exemplars do |c|
          c.excluded = true
        end
      end

      GridFour.new.js_columns.detect{|c| c[:name] == 'exemplars'}.should be_nil
    end
  end
end
