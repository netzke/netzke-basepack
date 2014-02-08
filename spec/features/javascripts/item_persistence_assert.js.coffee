describe "ItemPersistence component", ->
  it "asserts previously set region sizes", ->
    expect(westRegion().getWidth()).to.eql 110
    expect(eastRegion().getWidth()).to.eql 220

  it "asserts previously collapsed region", ->
    expect(!!southRegion().collapsed).to.eql true
