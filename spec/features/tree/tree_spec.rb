require 'spec_helper'
feature Netzke::Basepack::Tree do
  before do
    @file1 = FileRecord.create(file_name: 'file1', size: 100)
    @file2 = FileRecord.create(file_name: 'file2', size: 200)
    @dir3 = FileRecord.create(file_name: 'dir3', leaf: false)

    @file11 = FileRecord.create(file_name: 'file11', parent: @dir3, size: 1100)
    @dir12 = FileRecord.create(file_name: 'dir12', leaf: false, parent: @dir3)

    @file111 = FileRecord.create(file_name: 'file111', parent: @dir12, size: 11100)
  end

  it 'performs CRUD operations', js: true do
    run_mocha_spec 'tree/crud'
  end

  it 'stores expand/collapse node state', js: true do
    run_mocha_spec 'tree/node_state'
  end
end
