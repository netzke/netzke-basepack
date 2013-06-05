describe 'Grid::Sorting', ->
  it 'sorts by regular column', (done) ->
    wait ->
      grid().getStore().sort('title')
      wait ->
        expect(valuesInColumn('title')).to.eql ['Avatar', 'Belief', 'Cosmos']
        grid().getStore().sort('title', 'desc')
        wait ->
          expect(valuesInColumn('title')).to.eql ['Cosmos', 'Belief', 'Avatar']
          done()
