describe 'Grid pagination', ->
  it 'shows number of pages in the paging toolbar', (done) ->
    wait ->
      expect(Ext.dom.Query.selectValue(".x-toolbar-text:last")).to.equal "of 2"
      done()
