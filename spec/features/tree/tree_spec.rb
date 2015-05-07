require 'spec_helper'
feature Netzke::Basepack::Tree do
  before do
    file1 = FileRecord.create(name: 'file1', size: 100)
    file2 = FileRecord.create(name: 'file2', size: 200)
    dir3 = FileRecord.create(name: 'dir3', is_dir: true)

    file11 = FileRecord.create(name: 'file11', parent: dir3, size: 1100)
    dir12 = FileRecord.create(name: 'dir12', is_dir: true, parent: dir3)

    file111 = FileRecord.create(name: 'file111', parent: dir12, size: 11100)
  end

  it 'performs CRUD operations', js: true do
    run_mocha_spec 'tree/crud', stop_on_error: true
  end
end
