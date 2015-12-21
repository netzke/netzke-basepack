describe 'Grid::DefaultValues', ->
  it 'adds record via form', (done) ->
    click button 'Add'
    wait().then ->
      click button 'OK'
      wait()
    .then ->
      selectLastRow()
      expect(rowDisplayValues()).to.eql ['Lolita', 'Nabokov', '100', true]
      done()
