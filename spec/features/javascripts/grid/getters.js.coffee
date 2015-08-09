describe 'Grid::Getters', ->
  it 'shows specified by getters column values', (done) ->
    wait ->
      # 1 column - getter on relation(book -> author -> getter)
      # 2 column - getter on relation through relation(book -> author -> books -> first -> getter)
      # 3 column - getter without relation
      selectFirstRow()
      expect(rowDisplayValues()).to.eql ['Carlos Castaneda (10)', 'The Teachings of Don Juan(1968-01-01)', 'The Teachings of Don Juan, published 1968-01-01']
      selectLastRow()
      expect(rowDisplayValues()).to.eql ['Carlos Castaneda (10)', 'The Teachings of Don Juan(1968-01-01)', 'Journey to Ixtlan']
      done()


