require 'spec_helper'
feature Netzke::Basepack::Tree do
  before do
    root = FileRecord.create(name: 'root', is_dir: true)

    file1 = FileRecord.create(name: 'file1', parent: root, size: 100)
    file2 = FileRecord.create(name: 'file2', parent: root, size: 200)
    dir3 = FileRecord.create(name: 'dir3', is_dir: true, parent: root)

    file11 = FileRecord.create(name: 'file11', parent: dir3, size: 1100)
    dir12 = FileRecord.create(name: 'dir12', is_dir: true, parent: dir3)

    file111 = FileRecord.create(name: 'file111', parent: dir12, size: 11100)
  end

  it 'performs CRUD operations', js: true do
    run_mocha_spec 'tree/crud'
  end
end
