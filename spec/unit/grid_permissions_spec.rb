# Encoding: utf-8
require 'spec_helper'
describe Netzke::Grid::Permissions do
  context "in read-only mode" do
    class PermissionsOne < Netzke::Grid::Base
      def configure(c)
        super
        c.model = Book
        c.read_only = true
      end
    end

    let(:grid) { PermissionsOne.new }
    let(:client) { Netzke::Core::EndpointResponse.new }

    describe "#allowed_to?" do
      it "only permits reading in read_only mode" do
        expect(grid.allowed_to?(:create)).to eql false
        expect(grid.allowed_to?(:read)).to eql true
        expect(grid.allowed_to?(:update)).to eql false
        expect(grid.allowed_to?(:delete)).to eql false
      end
    end

    describe "#bbar" do
      it "does not show data changing actions on bbar" do
        expect(grid.bbar).to eql [:search]
      end
    end

    describe "#attempt_operation" do
      it "does not allow create operation" do
        grid.attempt_operation(:create, [], client)
        expect(client.to_s).to include "You don't have permissions to create data"
      end

      it "does not allow update operation" do
        grid.attempt_operation(:update, [], client)
        expect(client.to_s).to include "You don't have permissions to update data"
      end

      it "does not allow delete operation" do
        grid.attempt_operation(:delete, [], client)
        expect(client.to_s).to include "You don't have permissions to delete data"
      end

      it "allows read operation" do
        grid.attempt_operation(:read, {}, client)
        expect(client.to_s).to_not include "You don't have permissions to read data"
      end
    end
  end

  it "prohibits selected operations" do
    class PermissionsTwo < Netzke::Grid::Base
      def configure(c)
        super
        c.model = Book
        c.permissions = {create: false, delete: false}
      end
    end

    grid = PermissionsTwo.new
    expect(grid.allowed_to?(:create)).to eql false
    expect(grid.allowed_to?(:read)).to eql true
    expect(grid.allowed_to?(:update)).to eql true
    expect(grid.allowed_to?(:delete)).to eql false

    expect(grid.bbar).to include(:edit, :search)
  end

  context "prohibited read" do
    class PermissionsThree < Netzke::Grid::Base
      def configure(c)
        super
        c.model = Book
        c.permissions = {read: false}
      end
    end

    let(:grid) { PermissionsThree.new }
    let(:client) { Netzke::Core::EndpointResponse.new }

    describe "#allowed_to?" do
      it "prohibits reading data" do
        expect(grid.allowed_to?(:create)).to eql true
        expect(grid.allowed_to?(:read)).to eql false
        expect(grid.allowed_to?(:update)).to eql true
        expect(grid.allowed_to?(:delete)).to eql true
      end
    end

    describe "#attempt_operation" do
      it "does not allow reading" do
        grid.attempt_operation(:read, {}, client)
        expect(client.to_s).to include "You don't have permissions to read data"
      end
    end
  end
end
