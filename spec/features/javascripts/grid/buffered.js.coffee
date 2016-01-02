describe 'Grid::Buffered component', ->
  it 'loads data when scrolled', ->
    wait().then ->
      grid().getView().scrollBy(0, 10000)
      wait(500)
    .then ->
      selectRow(400)
      expect(rowDisplayValues()).to.eql(["First name 400"])
