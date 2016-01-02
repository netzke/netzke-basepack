window.expandNode = ->
  node = grid().getSelectionModel().getSelection()[0]
  node.expand()

describe 'Tree::Crud', ->
  it 'loads node children', ->
    wait().then ->
      expect(valuesInColumn('file_name')).to.eql ['file1', 'file2', 'dir3']
      selectLastRow()
      expandNode()
      wait()
    .then ->
      expect(grid().getStore().getCount()).to.eql(5)
      expect(valuesInColumn('file_name')).to.eql ['file1', 'file2', 'dir3', 'file11', 'dir12']

  it 'creates child node', ->
    selectLastRow()
    click button "Add"
    wait().then ->
      fill textfield('file_name'), with: 'New file'
      click button 'OK'
      wait()
    .then ->
      expect(valuesInColumn('file_name')).to.eql ['file1', 'file2', 'dir3', 'file11', 'dir12', 'file111', 'New file']

  it 'creates top-level node', ->
    grid().getSelectionModel().deselectAll()
    click button "Add"
    wait().then ->
      fill textfield('file_name'), with: 'file3'
      click button 'OK'
      wait()
    .then ->
      expect(valuesInColumn('file_name')).to.eql ['file1', 'file2', 'dir3', 'file11', 'dir12', 'file111', 'New file', 'file3']

  it 'deletes single record', ->
    wait().then ->
      selectFirstRow()
      click button 'Delete'
      click button 'Yes'
      wait()
    .then ->
      wait()
    .then ->
      expect(valuesInColumn('file_name')).to.eql ['file2', 'dir3', 'file11', 'dir12', 'file111', 'New file', 'file3']
