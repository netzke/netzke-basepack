describe 'Grid::Buffered component', ->
  it 'loads data when scrolled', ->
    wait().then ->
      grid().getView().scrollBy(0, 12800)
      wait(500)
    .then ->
      selectRow(400)
      wait()
    .then ->
      expect(rowDisplayValues()).to.eql(["First name 400"])
