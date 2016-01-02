describe 'Grid::CrudPaging', ->
  it 'creates single record via form', ->
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

  it 'updates record via form', ->
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

  it 'simultaneously updates two records via form', ->
    wait().then ->
      click button 'Add'
      wait()
    .then ->
      fill textfield('title'), with: 'Damian'
      click button 'OK'
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
      selectFirstRow()
      expect(rowDisplayValues()).to.eql ['Herman Hesse', 'Steppenwolf']
      selectLastRow()
      expect(rowDisplayValues()).to.eql ['Herman Hesse', 'Steppenwolf']

  it 'deletes records', ->
    wait().then ->
      selectAllRows()
      click button 'Delete'
      click button 'Yes'
      wait ->
        expect(grid().getStore().getCount()).to.eql(0)
