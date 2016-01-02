describe 'Grid::VirtualAttributes component', ->
  it 'deletes a record when delete column action is clicked', ->
    wait().then ->
      addRecord title: 'Damian', borrowed: 10
      click button 'Apply'
      wait()
    .then ->
      selectLastRow()
      expect(rowDisplayValues()).to.eql ['Damian', '10', 'Borrowed to: 10']
