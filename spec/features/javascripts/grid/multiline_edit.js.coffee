describe 'Grid::MultilineEdit', ->
  it 'simultaneously updates two records via form', ->
    wait().then ->
      addRecord title: 'Damian'
      addRecord title: 'Steppenwolf'
      completeEditing()
      click button 'Apply'
      wait()
    .then ->
      selectAllRows()
      click button 'Edit'
      wait()
    .then ->
      fill textfield('title'), with: 'Steppenwolf'
      expandCombo 'author__name'
      wait()
    .then ->
      select 'Herman Hesse', in: combobox 'author__name'
      click button 'OK'
      wait()
    .then ->
      wait()
    .then ->
      expect(valuesInColumn('author__name')).to.eql ['Herman Hesse', 'Herman Hesse']
      expect(valuesInColumn('title')).to.eql ['Steppenwolf', 'Steppenwolf']
