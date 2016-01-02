describe 'Grid::ActionColumn component', ->
  it 'deletes a record when delete column action is clicked', ->
    wait().then ->
      expect(grid('Books').getStore().getCount()).to.eql 1
      click icon 'Delete row'
      click button 'Yes'
      wait()
    .then ->
      expect(grid('Books').getStore().getCount()).to.eql 0
