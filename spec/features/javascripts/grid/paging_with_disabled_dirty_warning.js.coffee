describe 'Grid::Paging component', ->
  it 'discards uncommitted changes on page without warning', (done) ->
    wait().then ->
      selectFirstRow()
      updateRecord title: 'New title'

      click button 'Next Page'
      wait()
    .then ->
      expect(valuesInColumn('title')).to.eql ['Three', 'Four']
      done()
