describe 'Grid::Search', ->
  it 'searches by plain attribute', ->
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

  it 'searches by association attribute', ->
    wait().then ->
      click button 'Search'
      click button 'Clear'
      wait()
    .then ->
      select 'Author last name', in: combobox('undefined_attr')
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
