describe 'Grid::Crud', ->
  it 'creates single record via form', (done) ->
    wait().then ->
      click button 'Add'
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
    click button 'Edit'
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
    click button 'Edit'
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
