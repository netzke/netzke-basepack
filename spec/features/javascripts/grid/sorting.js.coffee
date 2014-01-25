describe 'Grid::Sorting', ->
  it 'is is sorted initially', (done) ->
    wait ->
      expect(valuesInColumn('title')).to.eql ['Foo', 'Damian', 'Magus', 'Journey']
      done()

  it 'sorts by regular column', (done) ->
    wait ->
      grid().getStore().sort('title')
      wait ->
        expect(valuesInColumn('title')).to.eql ['Damian', 'Foo', 'Journey', 'Magus']
        grid().getStore().sort('title', 'desc')
        wait ->
          expect(valuesInColumn('title')).to.eql ['Magus', 'Journey', 'Foo', 'Damian']
          done()

  it 'sorts by association column', (done) ->
    wait ->
      grid().getStore().sort('author__last_name')
      wait ->
        expect(valuesInColumn('title')).to.eql ['Foo', 'Journey', 'Magus', 'Damian']
        grid().getStore().sort('author__last_name', 'desc')
        wait ->
          expect(valuesInColumn('title')).to.eql ['Damian', 'Magus', 'Journey', 'Foo']
          done()
