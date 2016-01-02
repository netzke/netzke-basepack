describe 'Form::FileUpload', ->
  it 'creates record', ->
    fill textfield('title'), with: 'Picture'
    click button 'Apply'
    wait().then ->
      expectToSee header "Updated title"
