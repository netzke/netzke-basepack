describe 'Grid::MetaColumn component', ->
  it 'loads data when scrolled', ->
    wait().then ->
      click button 'Show first'
      expectToSee header "Exemplars: 1000"
      click button 'Show second'
      expectToSee header "Exemplars: 2000"
