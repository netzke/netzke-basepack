describe 'Grid pagination', ->
  it 'shows number of pages in the paging toolbar', (done) ->
    wait ->
      expect(Ext.dom.Query.selectValue(".x-toolbar-text:last")).to.equal "of 2"
      expect(valuesInColumn('title')).to.eql ['One', 'Two']
      click button 'Next Page'
      wait ->
        expect(valuesInColumn('title')).to.eql ['Three', 'Four']
        done()
