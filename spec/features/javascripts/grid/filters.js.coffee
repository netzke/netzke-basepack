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

  filter = grid.getColumnManager().getHeaderByDataIndex(column).filter

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
