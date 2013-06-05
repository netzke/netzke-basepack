describe 'Grid::DefaultValues', ->
  it 'adds single record inline', (done) ->
    click button 'Add'
    click button 'Apply'
    wait ->
      selectLastRow()
      expect(rowDisplayValues()).to.eql ['Lolita', 'Nabokov', '100', true]
      done()

  it 'adds record via form', (done) ->
    click button 'Add in form'
    wait ->
      click button 'OK'
      wait ->
        selectLastRow()
        expect(rowDisplayValues()).to.eql ['Lolita', 'Nabokov', '100', true]
        expect(grid().getStore().getCount()).to.eql 2
        done()
