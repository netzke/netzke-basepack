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
              searchField.setValue('')
              done()
          , 50
      , 50

  it 'searches by author full name', (done) ->
    wait ->
      searchField = Ext.ComponentQuery.query('field[attr="author__name"]')[0]
      gridStore = grid("Books").getStore()

      searchField.setValue('herman')
      setTimeout ->
        wait ->
          expect(gridStore.getCount()).to.eql(1)
          searchField.setValue('castaneda')
          setTimeout ->
            wait ->
              expect(gridStore.getCount()).to.eql(3)
              done()
          , 50
      , 50
