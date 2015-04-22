describe 'Grid::ActionColumn component', ->
  # Disabling, as the ActionColumn implementation is too unstable for now (FIXME)
  it 'deletes a record when delete column action is clicked', (done) ->
    wait().then ->
      expect(grid('Books').getStore().getCount()).to.eql 1
      click icon 'Delete row'
      click button 'Yes'
      wait()
    .then ->
      expect(grid('Books').getStore().getCount()).to.eql 0
      done()
