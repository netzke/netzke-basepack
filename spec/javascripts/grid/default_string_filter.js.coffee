describe 'Default string filter in Grid', ->
  it 'shows filtered records', (done) ->
    wait ->
      expect(grid("Books").getStore().getCount()).to.eql 1
      done()
