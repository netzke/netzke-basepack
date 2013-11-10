describe 'Form::WithoutModel', ->
  it 'submits different fields properly', (done) ->
    fill textfield('text_field'), with: 'Some text'
    fill numberfield('number_field'), with: '42'
    select 'Two', in: combobox 'combobox_field'
    # TODO other 3 fields

    click button 'Apply'
    wait ->
      expectToSee somewhere 'Text field: Some text'
      expectToSee somewhere 'Number field: 42'
      expectToSee somewhere 'Combobox field: 2'
      done()
