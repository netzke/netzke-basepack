describe 'SomeTabPanel component', ->
  it "loads a component to tab panel lazily", (done)->
    expectToSee button "Update html"

    click button "Panel Two"
    wait ->
      expectToSee button "Update html"

      click button "Update html"
      wait ->
        expectToSee header "Update for Panel Two"
        done()
