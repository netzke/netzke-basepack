describe 'Grid::Buffered component', ->
  it 'loads data when scrolled', (done) ->
    wait().then ->
      grid().getView().scrollBy(0, 10000)
      wait()
    .then ->
      selectRow(400)
      expect(rowDisplayValues()).to.eql(["First name 400"])
      done()
