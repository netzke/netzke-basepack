require 'spec_helper'

module Netzke::Basepack
  describe Attributes do
    it "declares attributes via DSL" do
      class AttributesTestOne < Netzke::Grid::Base
        def model
          Author
        end
        attribute :name do |c|
          c.read_only = false
        end
      end

      comp = AttributesTestOne.new
      expect(comp.attribute_overrides.keys).to eql([:id, :first_name, :last_name, :year, :prize_count, :created_at, :updated_at, :name])
      expect(comp.attribute_overrides[:name]).to eql(name: "name", read_only: false)
    end
  end
end
