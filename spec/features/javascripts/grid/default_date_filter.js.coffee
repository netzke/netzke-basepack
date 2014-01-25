describe 'Default date filter in Grid', ->
  it 'shows filtered records', (done) ->
    wait ->
      expect(grid("Books").getStore().getCount()).to.eql 2
      done()
