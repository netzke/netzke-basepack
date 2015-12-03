describe 'Grid::CrudInline', ->
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

  it 'simultaneously updates two records via form', (done) ->
    wait().then ->
      addRecord title: 'Damian'
      completeEditing()
      click button 'Apply'
      wait()
    .then ->
      selectAllRows()
      click button 'Edit'
      wait()
    .then ->
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
      expect(grid().getStore().getCount()).to.eql(2)
      selectFirstRow()
      expect(rowDisplayValues()).to.eql ['Herman Hesse', 'Steppenwolf']
      selectLastRow()
      expect(rowDisplayValues()).to.eql ['Herman Hesse', 'Steppenwolf']
      done()

  it 'deletes all records', (done) ->
    wait().then ->
      selectAllRows()
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

  it 'triggers cell editing when adding a record', (done) ->
    wait().then ->
      click button 'Add'
      expect(grid().getPlugin('celleditor').editing).to.eql true
      done()
