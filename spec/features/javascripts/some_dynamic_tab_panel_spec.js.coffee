describe 'SomeDynamicTabPanel component', ->
  it 'loads component in first tab', (done) ->
    click button 'Load in new tab'
    wait ->
      expectToSee tab "Component 1"
      done()

  it 'loads component in current tab', (done) ->
    click button 'Load in current tab'
    wait ->
      expectToNotSee tab "Component 1"
      expectToSee tab "Component 2"
      done()

  it 'loads component in new tab', (done) ->
    click button 'Load in new tab'
    wait ->
      expectToSee tab "Component 2"
      expectToSee tab "Component 3"
      done()
