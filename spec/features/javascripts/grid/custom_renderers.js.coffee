describe "Grid::CustomRenderers", ->
  it 'takes custom column renderers into account', ->
    wait ->
      expect(rowDisplayValues()).to.eql ['CARLOS', 'CASTANEDA', '*Journey to Ixtlan*']
