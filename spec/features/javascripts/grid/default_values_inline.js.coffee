describe 'Grid::DefaultValuesInline', ->
  it 'adds single record inline', (done) ->
    click button 'Add'
    click button 'Apply'
    wait ->
      selectFirstRow()
      expect(rowDisplayValues()).to.eql ['Lolita', 'Nabokov', '100', true]
      done()
