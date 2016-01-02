describe 'Grid::FileUpload', ->
  it 'creates record', ->
    wait().then ->
      click button 'Add'
      wait()
    .then ->
      fill textfield('title'), with: 'Painting'
      click button 'OK'
      wait()
