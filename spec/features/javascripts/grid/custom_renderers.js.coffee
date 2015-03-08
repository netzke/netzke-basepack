describe "Grid::CustomRenderers", ->
  it 'takes custom column renderers into account', ->
    wait ->
      selectFirstRow()
      expect(rowDisplayValues()).to.eql ['CARLOS', 'CASTANEDA', '*Journey to Ixtlan*']
