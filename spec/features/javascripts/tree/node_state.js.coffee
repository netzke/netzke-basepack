window.expandNode = ->
  node = grid().getSelectionModel().getSelection()[0]
  node.expand()

describe 'Tree::Crud', ->
  it 'remembers expand/collapse node state', (done) ->
    wait().then ->
      expect(valuesInColumn('name')).to.eql ['file1', 'file2', 'dir3']
      selectLastRow()
      expandNode()
      wait()
    .then ->
      selectLastRow()
      expandNode()
      wait()
    .then ->
      click tool 'refresh'
      wait()
    .then ->
      expect(valuesInColumn('name')).to.eql ['file1', 'file2', 'dir3', 'file11', 'dir12', 'file111']
      done()
