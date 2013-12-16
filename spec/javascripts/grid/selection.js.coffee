describe 'Grid row selection', ->
  it 'keeps row selection after grid reload', (done) ->
    wait ->
      selectAllRows()
      click tool 'refresh'
      wait ->
        expect(grid().getSelectionModel().getCount()).to.equal 4
        done()
