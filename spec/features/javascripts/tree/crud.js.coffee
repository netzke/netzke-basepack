window.expandNode = ->
  node = grid().getSelectionModel().getSelection()[0]
  node.expand()

describe 'Tree::Crud', ->
  it 'loads root node children', (done) ->
    selectFirstRow()
    expandNode()
    wait()
    .then ->
      expect(grid().getStore().getCount()).to.eql(4)
      selectLastRow()
      expect(valuesInColumn('file_size')).to.eql [0, 100, 200, 0]
      done()
