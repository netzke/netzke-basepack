describe 'Netzke::Form::Base', ->
  it 'edits a record', (done) ->
    expandCombo 'author__name'
    wait ->
      select 'Herman Hesse', in: combobox 'author__name'
      click button 'Apply'
      wait ->
        done()
