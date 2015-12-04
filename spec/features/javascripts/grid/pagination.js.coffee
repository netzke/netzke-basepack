describe 'Grid::Pagination component', ->
  it 'allows changing page on paging grid', (done) ->
    wait ->
      expect(Ext.dom.Query.selectValue(".x-toolbar-text:last")).to.equal "of 2"
      expect(valuesInColumn('title')).to.eql ['One', 'Two']
      click button 'Next Page'
      wait ->
        expect(valuesInColumn('title')).to.eql ['Three', 'Four']
        done()

  it 'discards uncommitted changes on page change when user is ok with that', (done) ->
    wait().then ->
      selectFirstRow()
      updateRecord title: 'New title'

      # simplate clicking "Cancel"
      window.confirm = -> false

      click button 'Previous Page'
      expect(valuesInColumn('title')).to.eql ['New title', 'Four']

      # simulate clicking "OK"
      window.confirm = -> true

      click button 'Previous Page'
      wait()
    .then ->
      expect(valuesInColumn('title')).to.eql ['One', 'Two']
      done()
