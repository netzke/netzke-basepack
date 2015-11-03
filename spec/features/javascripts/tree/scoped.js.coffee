window.expandNode = ->
  node = grid().getSelectionModel().getSelection()[0]
  node.expand()

describe 'Tree::Scoped', ->
  it 'shows scoped nodes only', (done) ->
    wait().then ->
      expect(valuesInColumn('file_name')).to.eql ['file1', 'file2', 'dir3']
      selectLastRow()
      expandNode()
      wait()
    .then ->
      expect(valuesInColumn('file_name')).to.eql ['file1', 'file2', 'dir3', 'file11']
      done()
