describe 'Grid::ProhibitRead component', ->
  it 'loads data without errors', (done) ->
    wait ->
      expectToSee somewhere "You don't have permissions to read data"
      done()
