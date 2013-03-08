describe 'SomeAccordion component', ->
  it 'lazily loads a component into a panel on its expansion' , (done) ->
    click header "Panel Two"

    wait ->
      click Ext
        .ComponentQuery
        .query("panel[collapsible=true][collapsed=false]")[0]
        .query("button[text=Update html]")[0]

      wait ->
        expectToSee panelWithContent "Update for Panel Two"
        done()

