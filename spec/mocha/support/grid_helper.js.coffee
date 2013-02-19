Ext.apply window,
  grid: (title) ->
    Ext.ComponentQuery.query('grid[title="'+title+'"]')[0]

  addRecords: ->
    params = arguments[arguments.length - 1]
    for record in arguments
      if (record != params)
        record = params.to.getStore().add(record)[0]
        record.isNew = true
    click button 'Apply' if params.submit

# Aliases
window.addRecord = window.addRecords
