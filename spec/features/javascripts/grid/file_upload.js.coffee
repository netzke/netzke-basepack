describe 'Grid::FileUpload', ->
  it 'creates record', (done) ->
    wait().then ->
      click button 'Add'
      wait()
    .then ->
      fill textfield('title'), with: 'Painting'
      click button 'OK'
      wait()
    .then ->
      done()
