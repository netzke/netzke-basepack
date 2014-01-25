Ext.Ajax.on 'beforerequest', ->
  Netzke.ajaxCount = window.ajaxCount || 0
  Netzke.ajaxCount += 1

Ext.Ajax.on 'requestcomplete', ->
  Netzke.ajaxCount -= 1

Ext.apply window,
  wait: (callback) ->
    i = 0
    id = setInterval ->
      i += 1
      if i >= 100 || Netzke.ajaxCount == 0
        clearInterval(id)
        callback.call()

      # this way we ensure another 20ms cycle before we issue a callback
      # callback.call() if Netzke.ajaxCount == 0
    , 100

  click: (cmp) ->
    if Ext.isString(cmp)
      throw "Could not locate " + cmp
    else if (cmp.isXType) # is Ext component
      if (cmp.isXType('tool'))
        # a hack needed for tools
        el = cmp.toolEl
      else
        el = cmp.getEl()

      el.dom.click()
    else if Ext.isElement(cmp)
      cmp.click()

  # Closes the first found window
  closeWindow: ->
    Ext.ComponentQuery.query("window[hidden=false]")[0].close()

  expandCombo: (name)->
    combo = Ext.ComponentQuery.query('combobox[name='+name+']')[0]
    combo.onTriggerClick()

  select: (value, params, callback) ->
    params ?= params
    combo = params.in
    if combo.isExpanded
      combo.setValue combo.findRecordByDisplay value
      combo.collapse()
    else
      combo.onTriggerClick()
      if callback
        wait ->
          rec = combo.findRecordByDisplay value
          combo.select rec
          combo.fireEvent('select', combo, rec )
          combo.collapse()
          callback.call()
      else
        rec = combo.findRecordByDisplay value
        combo.select rec
        combo.fireEvent('select', combo, rec )
        combo.collapse()

  fillIn: (name, value) ->
    field = Ext.ComponentQuery.query('textfield[name="'+name+'"]')[0]
    field.setValue(value)
