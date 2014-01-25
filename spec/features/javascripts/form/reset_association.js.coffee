describe 'Form', ->
  it 'resets associations', (done) ->
    fill textfield('title'), with: 'Damian'
    expandCombo 'author__name'
    wait ->
      select '---', in: combobox 'author__name'
      click button 'Apply'
      wait ->
        done()
