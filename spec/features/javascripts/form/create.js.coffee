describe 'Form::Create', ->
  it 'creates a record', (done) ->
    fill textfield('title'), with: 'Damian'
    expandCombo 'author__name'
    wait ->
      select 'Herman Hesse', in: combobox 'author__name'
      click button 'Apply'
      wait ->
        done()
