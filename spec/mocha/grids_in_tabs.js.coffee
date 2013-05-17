describe "GridsInTabs component", ->
  it 'properly loads data in both grids', (done) ->
    wait ->
      expect(grid('One').getStore().getCount()).to.eql(3)
      expect(grid('Two').getStore().getCount()).to.eql(3)
      done()
