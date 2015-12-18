window.enableColumnFilter = ->
  column = arguments[0]
  value = arguments[1]
  options = {}

  lastArg = arguments[arguments.length - 1]

  if Ext.isFunction lastArg
    callback = lastArg
  else if Ext.isObject lastArg
    options = lastArg

  { grid } = options

  grid ||= window.grid()

  filter = grid.columns.filter((c) -> c.name == column)[0].filter

  filter.setValue(value)

  setTimeout ->
    wait ->
      callback.call()
  , 500

describe 'Grid filter functionality', ->
  it 'filters by text', (done) ->
    wait ->
      grid().filters.clearFilters()
      enableColumnFilter "notes", "read", ->
        expect(grid("Books").getStore().getCount()).to.eql 2
        done()
  it 'filters by title_or_notes and price_or_exemplars', (done) ->
    wait ->
      grid().filters.clearFilters()
      enableColumnFilter "title_or_notes", "read", ->
        enableColumnFilter "price_or_exemplars", 5, ->
          expect(grid("Books").getStore().getCount()).to.eql 1
          done()

  # Do not ask me why filter.setValue(), when called on the TriFilter, does not send filter params to the server.
  # What's left to do? Test manually.
  # it 'filters by float', (done) ->
  #   wait ->
  #     grid().filters.clearFilters()
  #     enableColumnFilter "exemplars", {eq: 3}, ->
  #       expect(grid("Books").getStore().getCount()).to.eql 1
  #       done()
