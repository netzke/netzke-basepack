window.expandNode = ->
  node = grid().getSelectionModel().getSelection()[0]
  node.expand()

describe 'Tree::Crud', ->
  it 'loads node children', (done) ->
    wait().then ->
      expect(valuesInColumn('file_name')).to.eql ['file1', 'file2', 'dir3']
      selectLastRow()
      expandNode()
      wait()
    .then ->
      expect(grid().getStore().getCount()).to.eql(5)
      expect(valuesInColumn('file_name')).to.eql ['file1', 'file2', 'dir3', 'file11', 'dir12']
      done()

  it 'creates child node', (done) ->
    selectLastRow()
    click button "Add"
    wait().then ->
      fill textfield('file_name'), with: 'New file'
      click button 'OK'
      wait()
    .then ->
      expect(valuesInColumn('file_name')).to.eql ['file1', 'file2', 'dir3', 'file11', 'dir12', 'file111', 'New file']
      done()

  it 'creates top-level node', (done) ->
    grid().getSelectionModel().deselectAll()
    click button "Add"
    wait().then ->
      fill textfield('file_name'), with: 'file3'
      click button 'OK'
      wait()
    .then ->
      expect(valuesInColumn('file_name')).to.eql ['file1', 'file2', 'dir3', 'file11', 'dir12', 'file111', 'New file', 'file3']
      done()

  it 'deletes single record', (done) ->
    wait().then ->
      selectFirstRow()
      click button 'Delete'
      click button 'Yes'
      wait()
    .then ->
      wait()
    .then ->
      expect(valuesInColumn('file_name')).to.eql ['file2', 'dir3', 'file11', 'dir12', 'file111', 'New file', 'file3']
      done()
