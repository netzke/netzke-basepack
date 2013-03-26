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

  button: (text) ->
    Ext.ComponentQuery.query("button{isVisible(true)}[text='"+text+"']")[0] ||
      Ext.DomQuery.select("[data-qtip=#{text}]")[0] ||
      "button " + text

  tool: (type) ->
    Ext.ComponentQuery.query("tool{isVisible(true)}[type='"+type+"']")[0] ||
      'tool ' + type

  component: (id) ->
    Ext.ComponentQuery.query("panel{isVisible(true)}[id='"+id+"']")[0] ||
      'component ' + id

  icon: (tooltip) ->
    Ext.DomQuery.select('img[data-qtip="'+tooltip+'"]')[0] || 'icon ' + tooltip

  somewhere: (text) ->
    Ext.DomQuery.select("*:contains(" + text + ")")[0] || 'anywhere ' + text

  textFieldWith: (text) ->
    _componentLike "textfield", "value", text

  _componentLike:(type,attr,value)->
    Ext.ComponentQuery.query(type+'['+attr+'='+value+']')[0]

# alias
window.anywhere = window.somewhere
