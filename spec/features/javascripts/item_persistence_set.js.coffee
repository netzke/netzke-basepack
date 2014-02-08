describe "ItemPersistence component", ->
  it "sets new region sizes", (done) ->
    expect(westRegion().getWidth()).to.eql 100
    expect(eastRegion().getWidth()).to.eql 200

    westRegion().setWidth 110
    eastRegion().setWidth 220
    wait ->
      done()

  it "collapses south region", (done) ->
    collapse = (panel) ->
      panel.collapse(undefined, false)

    collapse southRegion()
    wait ->
      done()
