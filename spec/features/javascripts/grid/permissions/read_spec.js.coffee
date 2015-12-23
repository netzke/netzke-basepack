describe 'Grid::Permissions::Read component', ->
  it 'loads data without errors', (done) ->
    wait ->
      expectToSee somewhere "You don't have permissions to read data"
      done()
