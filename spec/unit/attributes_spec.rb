require 'spec_helper'

module Netzke::Basepack
  describe Attributes do
    it "declares attributes via DSL" do
      class AttributesTestOne < Netzke::Base
        include Netzke::Basepack::Attributes

        attribute :name do |c|
          c.read_only = true
        end
      end

      comp = AttributesTestOne.new
      expect(comp.attribute_overrides.keys).to eql([:name])
      expect(comp.attribute_overrides[:name]).to eql(name: "name", read_only: true)
    end
  end
end
