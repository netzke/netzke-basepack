describe 'Form',
  it 'shows validation errors', (done) ->
    click button 'Apply'
    wait ->
      expectToSee somewhere "Title can't be blank"
      fill textfield('title'), with: 'Brave new world'
      click button 'Apply'
      wait ->
        done()
