describe 'Grid::Search', ->
  it 'searches by plain attribute', (done) ->
    wait()
    .then ->
      click button 'Search'
      wait()
    .then ->
      select 'Title', in: combobox('undefined_attr')
      wait()
    .then ->
      fill textfield('title_value'), with: 'of'
      click(button 'Search', within: panel('grid_search__search_window'))
      wait()
    .then ->
      expect(grid().getStore().getCount()).to.eql 2
      click button 'Search'
      fill textfield('title_value'), with: 'r'
      click(button 'Search', within: panel('grid_search__search_window'))
      wait()
    .then ->
      expect(grid().getStore().getCount()).to.eql 3
      click button 'Search'
      fill textfield('title_value'), with: 'foobar'
      click(button 'Search', within: panel('grid_search__search_window'))
      wait()
    .then ->
      expect(grid().getStore().getCount()).to.eql 0
      done()

  it 'searches by association attribute', (done) ->
    wait().then ->
      click button 'Search'
      click button 'Clear'
      wait()
    .then ->
      select 'Author', in: combobox('undefined_attr')
      wait()
    .then ->
      fill textfield('author__last_name_value'), with: 'es'
      click(button 'Search', within: panel('grid_search__search_window'))
      wait()
    .then ->
      expect(grid().getStore().getCount()).to.eql 1
      click button 'Search'
      fill textfield('author__last_name_value'), with: 'cas'
      click(button 'Search', within: panel('grid_search__search_window'))
      wait()
    .then ->
      expect(grid().getStore().getCount()).to.eql 3
      done()
