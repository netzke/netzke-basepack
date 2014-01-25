describe "Grid::InTabs component", ->
  it 'properly loads data in both grids', (done) ->
    wait ->
      expect(grid('One').getStore().getCount()).to.eql(2)
      expect(grid('Two').getStore().getCount()).to.eql(2)
      done()
