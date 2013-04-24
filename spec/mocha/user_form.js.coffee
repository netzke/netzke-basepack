describe 'UserForm component', ->
  it 'shows the data for the first user', ->
    expectToSee textFieldWith "Carlos"
    expectToSee textFieldWith "Castaneda"
    expectToSee comboboxWith "writer"
