describe 'Grid::Crud', ->
  it 'creates single record inline', (done) ->
    wait ->
      addRecord title: 'Damian'
      selectAssociation 'author__name', 'Herman Hesse', ->
        completeEditing()
        click button 'Apply'
        wait ->
          wait ->
            expect(rowDisplayValues()).to.eql ['Herman Hesse', 'Damian']
            done()

  it 'updates single record inline', (done) ->
    wait ->
      selectFirstRow()
      updateRecord title: 'Art of Dreaming'
      selectAssociation 'author__name', 'Carlos Castaneda', ->
        completeEditing()
        click button 'Apply'
        wait ->
          wait ->
            expect(rowDisplayValues()).to.eql ['Carlos Castaneda', 'Art of Dreaming']
            done()

  it 'deletes records', (done) ->
    wait ->
      selectAllRows()
      click button 'Delete'
      click button 'Yes'
      wait ->
        expect(grid().getStore().getCount()).to.eql(0)
        done()

  it 'creates multiple records inline', (done) ->
    wait ->
      addRecord title: 'Damian'
      selectAssociation 'author__name', 'Herman Hesse', ->
        completeEditing()
        addRecord title: 'Art of Dreaming'
        selectAssociation 'author__name', 'Carlos Castaneda', ->
          completeEditing()
          click button 'Apply'
          wait ->
            wait ->
              expect(rowDisplayValues()).to.eql ['Carlos Castaneda', 'Art of Dreaming']
              selectFirstRow()
              expect(rowDisplayValues()).to.eql ['Herman Hesse', 'Damian']
              done()

  it 'gives a validation error when trying to add an invalid record', (done) ->
    wait ->
      addRecord exemplars: 3 # title is missing
      click button 'Apply'
      wait ->
        expectToSee anywhere "Title can't be blank"
        expect(grid('Books').getStore().getModifiedRecords().length).to.eql(1)
        editLastRow {title: 'Foo'}
        click button 'Apply'
        wait ->
          expect(grid('Books').getStore().getModifiedRecords().length).to.eql(0)
          done()
