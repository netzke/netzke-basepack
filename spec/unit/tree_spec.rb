require 'spec_helper'
describe Netzke::Basepack::Tree do
  let(:tree) { Tree::Crud.new }

  before do
    file1 = FileRecord.create(name: 'file1', size: 100)
    file2 = FileRecord.create(name: 'file2', size: 200)
    dir3 = FileRecord.create(name: 'dir3', leaf: false, expanded: true)

    file11 = FileRecord.create(name: 'file11', parent: dir3, size: 1100)
    dir12 = FileRecord.create(name: 'dir12', leaf: false, parent: dir3, expanded: true)

    file111 = FileRecord.create(name: 'file111', parent: dir12, size: 11100)
  end

  describe '#read' do
    it 'includes children recursively' do
      node_tree = tree.read(id: 'root')
      expect(node_tree[:children].last[:children].last[:children].last[:name]).to eql 'file111'
    end
  end
end
