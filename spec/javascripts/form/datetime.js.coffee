describe 'Form', ->
  it 'sets date and datetime', (done) ->
    fill textfield('title'), with: 'Brave new world'
    fill datefield('published_on'), with: '2005-01-23'
    fill xdatetime('last_read_at'), with: '2005-01-23 11:12:13'
    click button 'Apply'
    wait ->
      done()
