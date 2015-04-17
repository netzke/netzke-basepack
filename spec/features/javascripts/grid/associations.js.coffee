describe 'Grid with associations', ->
  it 'shows association values properly', (done) ->
    wait ->
      selectFirstRow()
      expect(rowDisplayValues()).to.eql ['A Book', 'Carlos', '0']
      done()
