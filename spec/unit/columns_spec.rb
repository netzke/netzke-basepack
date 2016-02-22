require 'spec_helper'

module Netzke::Basepack
  describe Columns do
    it "provides correct list of default fields for forms" do
      fields = ::Grid::CustomColumns.new.send :default_form_items
      expect(fields).to eql %w[author__first_name author__last_name author__name title digitized rating exemplars updated_at extra_column].map(&:to_sym)
    end

    it "allows overriding columns" do
      class GridOne < Netzke::Grid::Base
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
      expect(columns.detect{|c| c[:name] == 'title'}[:renderer]).to eql 'uppercase'
    end

    it 'prepends primary key column automatically when columns are listed explicitely' do
      class GridTwo < Netzke::Grid::Base
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
      expect(columns.detect{|c| c[:name] == 'id'}[:hidden]).to_not eql true # not hidden by default in Ext JS grid
    end

    it 'makes virtual attributes not editable and not sortable by default' do
      class GridThree < Netzke::Grid::Base
        def configure(c)
          super
          c.model = Book
          c.columns = [:in_abundance]
        end

        column :in_abundance do |c|
          c.getter = lambda { true }
        end
      end
      column = GridThree.new.js_columns.detect{|c| c[:name] == 'in_abundance'}
      expect(column[:read_only]).to eql true
      expect(column[:sortable]).to eql false
    end

    it 'does not render excluded columns' do
      class GridFour < Netzke::Grid::Base
        def configure(c)
          super
          c.model = Book
        end

        column :exemplars do |c|
          c.excluded = true
        end
      end

      expect(GridFour.new.js_columns.detect{|c| c[:name] == 'exemplars'}).to be_nil
    end
  end
end
