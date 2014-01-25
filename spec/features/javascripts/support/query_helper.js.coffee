Ext.apply window,
  currentPanelTitle: ->
    panel = Ext.ComponentQuery.query('panel[hidden=false]')[0]
    throw "Panel not found" if !panel
    panel.getHeader().title

  header: (title) ->
    Ext.ComponentQuery.query('header{isVisible(true)}[title="'+title+'"]')[0] ||
      'header ' + title

  tab: (title) ->
    Ext.ComponentQuery.query('tab[text="'+title+'"]')[0] || 'tab ' + title

  panelWithContent: (text) ->
    Ext.DomQuery.select("div.x-panel-body:contains(" + text + ")")[0] ||
      'panel with content ' + text

  button: (text, params) ->
    params ?= {}
    context = params.within

    query = "button{isVisible(true)}[text='"+text+"']"
    if context
      context.query(query)[0] || 'button ' + text
    else
      Ext.ComponentQuery.query(query)[0] ||
        Ext.DomQuery.select("[data-qtip=#{text}]")[0] ||
        "button " + text

  panel: (name, params) ->
    Ext.getCmp(name)

  tool: (type) ->
    Ext.ComponentQuery.query("tool{isVisible(true)}[type='"+type+"']")[0] ||
      'tool ' + type

  component: (id) ->
    Ext.ComponentQuery.query("panel{isVisible(true)}[id='"+id+"']")[0] ||
      'component ' + id

  combobox: (name) ->
    Ext.ComponentQuery.query("combo{isVisible(true)}[name='"+name+"']")[0] ||
      'combobox ' + name

  icon: (tooltip) ->
    Ext.DomQuery.select('img[data-qtip="'+tooltip+'"]')[0] || 'icon ' + tooltip

  activeWindow: ->
    Ext.WindowMgr.getActive()

  somewhere: (text) ->
    Ext.DomQuery.select("*:contains(" + text + ")")[0] || 'anywhere ' + text

  textFieldWith: (text) ->
    _componentLike "textfield", "value", text

  comboboxWith: (text) ->
    _componentLike "combo", "rawValue", text

  textAreaWith: (text) ->
    _componentLike "textareafield", "value", text

  numberFieldWith: (value) ->
    _componentLike "numberfield", "value", value

  dateTimeFieldWith: (value) ->
    res = 'xdatetime with value ' + value
    Ext.each Ext.ComponentQuery.query('xdatetime'), (item) ->
      if item.getValue().toString() == (new Date(value)).toString()
        res = item
        return
    res

  dateFieldWith: (value) ->
    res = 'datefield with value ' + value
    Ext.each Ext.ComponentQuery.query('datefield'), (item) ->
      if item.getValue().toString() == (new Date(value)).toString()
        res = item
        return
    res

  _componentLike:(type,attr,value)->
    Ext.ComponentQuery.query(type+'['+attr+'='+value+']')[0] || type + " with " + attr + " '" + value + "'"

# alias
window.anywhere = window.somewhere
