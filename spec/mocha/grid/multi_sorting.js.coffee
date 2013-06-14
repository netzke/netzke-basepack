describe 'Grid::MultiSorting', ->
  it 'loads data sorted properly', (done) ->
    wait ->
      expect(valuesInColumn('exemplars')).to.eql [1, 2, 2, 2, 2]
      expect(valuesInColumn('title')).to.eql ["B", "A", "B", "B", "B"]
      expect(valuesInColumn('author__last_name')).to.eql ["B", "A", "A", "B", "C"]
      done()
