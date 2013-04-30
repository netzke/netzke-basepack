Ext.apply window,
  grid: (title) ->
    Ext.ComponentQuery.query('grid[title="'+title+'"]')[0]

  # Example:
  # addRecords {title: 'Foo'}, {title: 'Bar'}, to: grid('Books'), submit: true
  addRecords: ->
    params = arguments[arguments.length - 1]
    for record in arguments
      if (record != params)
        record = params.to.getStore().add(record)[0]
        record.isNew = true
    click button 'Apply' if params.submit

  selectAllRowsIn: (grid) ->
    grid.getSelectionModel().selectAll()


  # Example:
  # editLastRow {title: 'Foo', exemplars: 10}
  editLastRow: ->
    data = arguments[0]
    grid = Ext.ComponentQuery.query("grid")[0]
    store = grid.getStore()
    record = store.last()
    for key of data
      record.set(key, data[key])

# Aliases
window.addRecord = window.addRecords
