require 'spec_helper'
feature Netzke::Tree::Base, js: true do
  before do
    @file1 = FileRecord.create(file_name: 'file1', size: 100)
    @file2 = FileRecord.create(file_name: 'file2', size: 200)
    @dir3 = FileRecord.create(file_name: 'dir3', leaf: false)

    @file11 = FileRecord.create(file_name: 'file11', parent: @dir3, size: 1100)
    @dir12 = FileRecord.create(file_name: 'dir12', leaf: false, parent: @dir3)

    @file111 = FileRecord.create(file_name: 'file111', parent: @dir12, size: 11100)
  end

  it 'performs CRUD operations' do
    run_mocha_spec 'tree/crud'
  end

  it 'performs CRUD operations inline' do
    run_mocha_spec 'tree/crud_inline'
  end

  it 'stores expand/collapse node state' do
    run_mocha_spec 'tree/node_state'
  end

  it 'allows to drag and drop nodes' do
    expect(@file1.parent_id).to be nil
    visit '/netzke/components/Tree::DragDrop'
    wait_for_ajax

    file1_element = first('div.x-grid-cell-inner', text: /\Afile1\z/ )
    dir3_element = first('div.x-grid-cell-inner', text: 'dir3')
    file1_element.drag_to(dir3_element)
    wait_for_ajax

    expect(@file1.reload.parent_id).to eq @dir3.id

    file1_element = first('div.x-grid-cell-inner', text: /\Afile1\z/)
    file2_element =  first('div.x-grid-cell-inner', text: 'file2')
    file1_element.drag_to(file2_element)
    wait_for_ajax

    expect(@file1.reload.parent_id).to be nil
  end
end
