describe 'Grid::Sorting', ->
  it 'is is sorted initially', (done) ->
    wait ->
      expect(valuesInColumn('title')).to.eql ['Foo', 'Damian', 'Magus', 'Journey']
      done()

  it 'sorts by regular column', (done) ->
    wait()
    .then ->
      grid().getStore().sort('title')
      wait()
    .then ->
      expect(valuesInColumn('title')).to.eql ['Damian', 'Foo', 'Journey', 'Magus']
      grid().getStore().sort('title', 'desc')
      wait()
    .then ->
      expect(valuesInColumn('title')).to.eql ['Magus', 'Journey', 'Foo', 'Damian']
      done()

  it 'sorts by association column', (done) ->
    wait()
    .then ->
      grid().getStore().sort('author__last_name')
      wait()
    .then ->
      expect(valuesInColumn('title')).to.eql ['Foo', 'Journey', 'Magus', 'Damian']
      grid().getStore().sort('author__last_name', 'desc')
      wait()
    .then ->
      expect(valuesInColumn('title')).to.eql ['Damian', 'Magus', 'Journey', 'Foo']
      done()
