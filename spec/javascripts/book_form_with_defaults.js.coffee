describe 'BookFormWithDefaults', ->
  it 'shows all fieldds properly', ->
    expectToSee textFieldWith "Journey to Ixtlan"
    expectToSee comboboxWith "Carlos Castaneda"
    expectToSee textAreaWith "A must read"
    expectToSee dateTimeFieldWith "23 Jan, 2005 11:12:13"
    expectToSee dateFieldWith "25 Jan, 2001"
    expectToSee numberFieldWith "3"
