describe 'Grid::DefaultValues', ->
  it 'adds record via form', ->
    wait().then ->
      click button 'Add'
      wait()
    .then ->
      click button 'OK'
      wait()
    .then ->
      selectLastRow()
      expect(rowDisplayValues()).to.eql ['Lolita', 'Nabokov', '100', true]
