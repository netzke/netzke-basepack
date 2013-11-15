describe 'GridWithFeedbackOnDataLoad component', ->
  it 'shows a message passed from server along with the data', (done) ->
    wait ->
      expectToSee somewhere 'Data loaded!'
      done()
