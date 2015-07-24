window.expandNode = ->
  node = grid().getSelectionModel().getSelection()[0]
  node.expand()

describe 'Tree::Crud', ->
  it 'loads node children', (done) ->
    wait().then ->
      expect(valuesInColumn('name')).to.eql ['file1', 'file2', 'dir3']
      selectLastRow()
      expandNode()
      wait()
    .then ->
      expect(grid().getStore().getCount()).to.eql(5)
      expect(valuesInColumn('name')).to.eql ['file1', 'file2', 'dir3', 'file11', 'dir12']
      done()

  it 'updates single record inline', (done) ->
    wait().then ->
      selectLastRow()
      updateRecord name: 'New dir name'
    .then ->
      completeEditing()
      expect(valuesInColumn('name')).to.eql ['file1', 'file2', 'dir3', 'file11', 'New dir name']
      click button 'Apply'
      wait()
    .then ->
      wait()
    .then ->
      selectFirstRow()
      expect(valuesInColumn('name')).to.eql ['file1', 'file2', 'dir3', 'file11', 'New dir name']
      done()

  it 'creates child node', (done) ->
    selectLastRow()
    click button "Add"
    wait().then ->
      fill textfield('name'), with: 'New file'
      click button 'OK'
      wait()
    .then ->
      expect(valuesInColumn('name')).to.eql ['file1', 'file2', 'dir3', 'file11', 'New dir name', 'file111', 'New file']
      done()

  it 'creates top-level node', (done) ->
    grid().getSelectionModel().deselectAll()
    click button "Add"
    wait().then ->
      fill textfield('name'), with: 'file3'
      click button 'OK'
      wait()
    .then ->
      expect(valuesInColumn('name')).to.eql ['file1', 'file2', 'dir3', 'file11', 'New dir name', 'file111', 'New file', 'file3']
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
      expect(valuesInColumn('name')).to.eql ['file2', 'dir3', 'file11', 'New dir name', 'file111', 'New file', 'file3']
      done()
