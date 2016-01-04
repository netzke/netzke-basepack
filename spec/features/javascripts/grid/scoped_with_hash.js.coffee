describe "Grid::ScopedWithHash component", ->
  it "shows 2 out of 3 records", (done) ->
    wait ->
      expect(grid().getStore().getCount()).to.eql 2
      done()
