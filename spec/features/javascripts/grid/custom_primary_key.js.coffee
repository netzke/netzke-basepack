describe 'Grid::CustomPrimaryKey', ->
  it 'creates single record inline', (done) ->
    wait ->
      addRecord title: 'Damian'
      selectAssociation 'author__name', 'Herman Hesse', ->
        completeEditing()
        click button 'Apply'
        wait ->
          wait ->
            selectLastRow()
            expect(rowDisplayValues()).to.eql ['Herman Hesse', 'Damian']
            done()
