describe 'Grid::Permissions::Update component', ->
  it 'does not load edit form on double click', (done) ->
    wait().then ->
      click button 'Add'
      wait()
    .then ->
      fill textfield('title'), with: 'Damian'
      click button 'OK'
      wait()
    .then ->
      selectLastRow()
      dblclickRow()
      wait()
    .then ->
      expectToNotSee header "Edit Book"
      done()
