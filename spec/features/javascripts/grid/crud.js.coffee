describe 'Grid::Crud', ->
  it 'creates single record inline', (done) ->
    wait().then ->
      addRecord title: 'Damian'
      selectAssociation 'author__name', 'Herman Hesse'
    .then ->
      completeEditing()
      click button 'Apply'
      wait()
    .then ->
      wait()
    .then ->
      selectFirstRow()
      expect(rowDisplayValues()).to.eql ['Herman Hesse', 'Damian']
      done()

  it 'updates single record inline', (done) ->
    wait().then ->
      selectFirstRow()
      updateRecord title: 'Art of Dreaming'
      selectAssociation 'author__name', 'Carlos Castaneda'
    .then ->
      completeEditing()
      expect(rowDisplayValues()).to.eql ['Carlos Castaneda', 'Art of Dreaming']
      click button 'Apply'
      wait()
    .then ->
      wait()
    .then ->
      selectFirstRow()
      expect(rowDisplayValues()).to.eql ['Carlos Castaneda', 'Art of Dreaming']
      done()

  it 'deletes single record', (done) ->
    wait().then ->
      selectFirstRow()
      click button 'Delete'
      click button 'Yes'
      wait()
    .then ->
      expect(grid().getStore().getCount()).to.eql(0)
      done()

  it 'creates multiple records inline', (done) ->
    wait().then ->
      addRecord title: 'Damian'
      selectAssociation 'author__name', 'Herman Hesse'
    .then ->
      completeEditing()
      addRecord title: 'Art of Dreaming'
      selectAssociation 'author__name', 'Carlos Castaneda'
    .then ->
      completeEditing()
      click button 'Apply'
      wait ->
    .then ->
      wait ->
        selectLastRow()
        expect(rowDisplayValues()).to.eql ['Carlos Castaneda', 'Art of Dreaming']
        selectFirstRow()
        expect(rowDisplayValues()).to.eql ['Herman Hesse', 'Damian']
        done()

  it 'gives a validation error when trying to add an invalid record', (done) ->
    wait().then ->
      addRecord exemplars: 3 # title is missing
      click button 'Apply'
      wait()
    .then ->
      expectToSee anywhere "Title can't be blank"
      expect(grid('Books').getStore().getModifiedRecords().length).to.eql(1)
      editLastRow {title: 'Foo'}
      click button 'Apply'
      wait ->
        expect(grid('Books').getStore().getModifiedRecords().length).to.eql(0)
        done()

  it 'creates single record via form', (done) ->
    wait().then ->
      click button 'Add in form'
      wait()
    .then ->
      fill textfield('title'), with: 'Damian'
      expandCombo 'author__name'
      wait()
    .then ->
      select 'Herman Hesse', in: combobox 'author__name'
      click button 'OK'
      wait()
    .then ->
      selectLastRow()
      expect(rowDisplayValues()).to.eql ['Herman Hesse', 'Damian']
      done()

  it 'updates record via form', (done) ->
    rowCount = grid('Books').getStore().getCount()
    selectLastRow()
    click button 'Edit in form'
    wait().then ->
      expectToSee textFieldWith "Damian"
      expectToSee comboboxWith "Herman Hesse"
      fill textfield('title'), with: 'Art of Dreaming'
      expandCombo 'author__name'
      wait()
    .then ->
      select 'Carlos Castaneda', in: combobox 'author__name'
      click button 'OK'
      wait()
    .then ->
      selectLastRow()
      expect(rowDisplayValues()).to.eql ['Carlos Castaneda', 'Art of Dreaming']
      expect(grid('Books').getStore().getCount()).to.eql rowCount
      done()

  it 'simultaneously updates all records via form', (done) ->
    selectAllRows()
    click button 'Edit in form'
    wait().then ->
      fill textfield('title'), with: 'Steppenwolf'
      expandCombo 'author__name'
      wait()
    .then ->
      select 'Herman Hesse', in: combobox 'author__name'
      click button 'OK'
      wait()
    .then ->
      wait()
    .then ->
      selectFirstRow()
      expect(rowDisplayValues()).to.eql ['Herman Hesse', 'Steppenwolf']
      selectLastRow()
      expect(rowDisplayValues()).to.eql ['Herman Hesse', 'Steppenwolf']
      done()

  it 'deletes records', (done) ->
    wait().then ->
      selectAllRows()
      click button 'Delete'
      click button 'Yes'
      wait ->
        expect(grid().getStore().getCount()).to.eql(0)
        done()
