describe 'Grid::DefaultValues', ->
  it 'adds record via form', (done) ->
    click button 'Add'
    wait ->
      click button 'OK'
      wait ->
        selectLastRow()
        expect(rowDisplayValues()).to.eql ['Lolita', 'Nabokov', '100', true]
        done()
