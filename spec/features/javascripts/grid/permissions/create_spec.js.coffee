describe 'Grid::Permissions::Create component', ->
  it 'does not show Add button', (done) ->
    wait ->
      expectToNotSee button "Add"
      done()
