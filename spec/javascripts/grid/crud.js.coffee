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

  it 'creates single record via form', (done) ->
    wait ->
      click button 'Add in form'
      wait ->
        fill textfield('title'), with: 'Damian'
        expandCombo 'author__name'
        wait ->
          select 'Herman Hesse', in: combobox 'author__name'
          click button 'OK'
          wait ->
            selectLastRow()
            expect(rowDisplayValues()).to.eql ['Herman Hesse', 'Damian']
            done()

  it 'updates record via form', (done) ->
    rowCount = grid('Books').getStore().getCount()
    selectLastRow()
    click button 'Edit in form'
    wait ->
      expectToSee textFieldWith "Damian"
      expectToSee comboboxWith "Herman Hesse"
      fill textfield('title'), with: 'Art of Dreaming'
      expandCombo 'author__name'
      wait ->
        select 'Carlos Castaneda', in: combobox 'author__name'
        click button 'OK'
        wait ->
          selectLastRow()
          expect(rowDisplayValues()).to.eql ['Carlos Castaneda', 'Art of Dreaming']
          expect(grid('Books').getStore().getCount()).to.eql rowCount
          done()

  it 'simultaneously updates all records via form', (done) ->
    selectAllRows()
    click button 'Edit in form'
    wait ->
      fill textfield('title'), with: 'Steppenwolf'
      expandCombo 'author__name'
      wait ->
        select 'Herman Hesse', in: combobox 'author__name'
        click button 'OK'
        wait ->
          wait ->
            selectFirstRow()
            expect(rowDisplayValues()).to.eql ['Herman Hesse', 'Steppenwolf']
            selectLastRow()
            expect(rowDisplayValues()).to.eql ['Herman Hesse', 'Steppenwolf']
            done()
