describe 'Grid with inline data', ->
  it 'shows inline data on initial load', ->
    expect(valuesInColumn('title')).to.eql ["One", "Two"]
