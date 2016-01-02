describe 'LiveSearch grid plugin', ->
  it 'searches by title', ->
    gridStore = grid("Books").getStore()
    searchField = Ext.ComponentQuery.query('field[attr="title"]')[0]

    wait().then ->
      searchField.setValue('of')
      wait 50
    .then ->
      expect(valuesInColumn('title')).to.eql ['The Art of Dreaming', 'Way of Warrior']
      searchField.setValue('war')
      wait 50
    .then ->
      expect(valuesInColumn('title')).to.eql ['Way of Warrior']
      searchField.setValue('')

  it 'searches by author full name', ->
    searchField = Ext.ComponentQuery.query('field[attr="author__name"]')[0]
    gridStore = grid("Books").getStore()

    wait().then ->
      searchField.setValue('castaneda')
      wait 50
    .then ->
      expect(valuesInColumn('title')).to.eql ['Journey to Ixtlan', 'The Art of Dreaming', 'Way of Warrior']
      searchField.setValue('herman')
      wait 50
    .then ->
      expect(valuesInColumn('title')).to.eql ['Damian']
      searchField.setValue('')

  it 'searches by column which is not shown', ->
    searchField = Ext.ComponentQuery.query('field[attr="notes"]')[0]
    gridStore = grid("Books").getStore()

    wait().then ->
      searchField.setValue('of')
      wait 50
    .then ->
      expect(valuesInColumn('title')).to.eql ['The Art of Dreaming', 'Way of Warrior']
      searchField.setValue('war')
      wait 50
    .then ->
      expect(valuesInColumn('title')).to.eql ['Way of Warrior']
      searchField.setValue('')
