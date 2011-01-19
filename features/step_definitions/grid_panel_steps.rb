When /^I select first row in the grid$/ do
  page.driver.browser.execute_script <<-JS
    var components = [];
    for (var cmp in Netzke.page) { components.push(cmp); }
    var grid = Netzke.page[components[0]];
    grid.getSelectionModel().selectFirstRow();
  JS
end

When /^I select all rows in the grid$/ do
  page.driver.browser.execute_script <<-JS
    var components = [];
    for (var cmp in Netzke.page) { components.push(cmp); }
    var grid = Netzke.page[components[0]];
    grid.getSelectionModel().selectAll();
  JS
end

Then /^the grid should show (\d+) records$/ do |arg1|
  page.driver.browser.execute_script(<<-JS).should == arg1.to_i
    var components = [];
    for (var cmp in Netzke.page) { components.push(cmp); }
    var grid = Netzke.page[components[0]];
    return grid.getStore().getCount();
  JS
end

When /^I edit row (\d+) of the grid with #{capture_fields}$/ do |rowIndex, fields|
  fields = ActiveSupport::JSON.decode("{#{fields}}")
  js_set_fields = fields.each_pair.map do |k,v|
    "r.set('#{k}', '#{v}');"
  end.join
  page.driver.browser.execute_script <<-JS
    var components = [];
    for (var cmp in Netzke.page) { components.push(cmp); }
    var grid = Netzke.page[components[0]];
    var r = grid.getStore().getAt(#{rowIndex.to_i-1});
    #{js_set_fields}
  JS
end

Then /^the grid should have (\d+) modified records$/ do |n|
  page.driver.browser.execute_script(<<-JS).should == n.to_i
    var components = [];
    for (var cmp in Netzke.page) { components.push(cmp); }
    var grid = Netzke.page[components[0]];
    return grid.getStore().getModifiedRecords().length;
  JS
end

When /^I enable filter on column "([^"]*)" with value "([^"]*)"$/ do |column, value|
  page.driver.browser.execute_script <<-JS
    var components = [];
    for (var cmp in Netzke.page) { components.push(cmp); }
    var grid = Netzke.page[components[0]];
    var filter = grid.filters.getFilter(grid.getColumnModel().getDataIndex(grid.getColumnModel().findColumnIndex('#{column}')));
    filter.setValue(#{value});
    filter.setActive(true);
  JS
end

When /^I clear all filters in the grid$/ do
  page.driver.browser.execute_script <<-JS
    var components = [];
    for (var cmp in Netzke.page) { components.push(cmp); }
    var grid = Netzke.page[components[0]];
    grid.filters.clearFilters();
  JS
end
