describe 'Grid::Search', ->
  it 'searches by plain attribute', (done) ->
    wait()
    .then ->
      click button 'Search'
      wait()
    .then ->
      select 'Title', in: combobox('undefined_attr')
      fillIn 'title_value', 'an'
      click(button 'Search', within: panel('grid_search__search_window'))
      wait()
    .then ->
      expect(grid().getStore().getCount()).to.eql 2
      click button 'Search'
      fillIn 'title_value', 'a'
      click(button 'Search', within: panel('grid_search__search_window'))
      wait()
    .then ->
      expect(grid().getStore().getCount()).to.eql 3
      click button 'Search'
      fillIn 'title_value', 'foo'
      click(button 'Search', within: panel('grid_search__search_window'))
      wait()
    .then ->
      expect(grid().getStore().getCount()).to.eql 1
      done()

  it 'searches by association attribute', (done) ->
    wait().then ->
      click button 'Search'
      click button 'Clear'
      wait()
    .then ->
      select 'Author last name', in: combobox('undefined_attr')
      fillIn 'author__last_name_value', 'es'
      click(button 'Search', within: panel('grid_search__search_window'))
      wait()
    .then ->
      expect(grid().getStore().getCount()).to.eql 2
      click button 'Search'
      fillIn 'author__last_name_value', 'fo'
      click(button 'Search', within: panel('grid_search__search_window'))
      wait()
    .then ->
      expect(grid().getStore().getCount()).to.eql 1
      done()
