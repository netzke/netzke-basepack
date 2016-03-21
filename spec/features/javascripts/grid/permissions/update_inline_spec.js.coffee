describe 'Grid::Permissions::UpdateInline component', ->
  it 'does not start editing on double click', ->
    wait().then ->
      addRecord title: 'Damian'
      click button 'Apply'
      wait()
    .then ->
      selectLastRow()
      dblclickRow()
      expect(!!grid().getPlugin('celleditor').editing).to.eql false
