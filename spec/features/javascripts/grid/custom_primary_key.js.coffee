describe 'Grid::CustomPrimaryKey', ->
  it 'creates single record inline', (done) ->
    wait()
    .then ->
      addRecord title: 'Damian'
      selectAssociation 'author__name', 'Herman Hesse'
    .then ->
      completeEditing()
      click button 'Apply'
      wait()
    .then ->
      wait()
    .then ->
      selectLastRow()
      expect(rowDisplayValues()).to.eql ['Herman Hesse', 'Damian']
      done()
