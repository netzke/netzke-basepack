describe 'GridWithLiveSearch component', ->
  it 'searches by title', (done) ->
    wait ->
      searchField = Ext.ComponentQuery.query('field[attr="title"]')[0]
      gridStore = grid("Books").getStore()

      searchField.setValue('of')
      setTimeout ->
        wait ->
          expect(gridStore.getCount()).to.eql(2)
          searchField.setValue('war')
          setTimeout ->
            wait ->
              expect(gridStore.getCount()).to.eql(1)
              done()
          , 50
      , 50
