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

  filter = grid.filters.getFilter(column)
  filter.setValue(value)

  # HACK: repeating to make filters really work
  filter = grid.filters.getFilter(column)
  filter.setValue(value)

  filter.setActive(true)

  setTimeout ->
    wait ->
      callback.call()
  , 500

window.clearAllColumnFilters = ->
  callback = arguments[0]
  grid().filters.clearFilters()
  setTimeout ->
    wait ->
      callback.call()
  , 500

describe 'Grid filter functionality', ->
  beforeEach (done) ->
    clearAllColumnFilters ->
      done()

  it 'filters by text', (done) ->
    wait ->
      enableColumnFilter "notes", "read", ->
        expect(grid("Books").getStore().getCount()).to.eql 2
        done()

  it 'filters by associated record text', (done) ->
    wait ->
      enableColumnFilter "author__first_name", "d", ->
        expect(grid("Books").getStore().getCount()).to.eql 2
        done()

  it 'filters by datetime', (done) ->
    wait ->
      enableColumnFilter "last_read_at", {on: new Date "2011/04/25"}, ->
        expect(grid("Books").getStore().getCount()).to.eql 1
        done()

  it 'filters by integer', (done) ->
    wait ->
      enableColumnFilter "exemplars", {gt: 6}, ->
        expect(grid("Books").getStore().getCount()).to.eql 1
        done()

  it 'filters by boolean', (done) ->
    wait ->
      enableColumnFilter "digitized", false, ->
        expect(grid("Books").getStore().getCount()).to.eql 1
        enableColumnFilter "digitized", true, ->
          expect(grid("Books").getStore().getCount()).to.eql 2
          done()
