describe "Grid::Books component", ->
  it "edits title for multiple records", (done) ->
    wait().then ->
      selectAllRows()
      click button 'Edit'
      wait()
    .then ->
      fill textfield('title'), with: 'C'
      click button 'OK'
      wait()
    .then ->
      done()
