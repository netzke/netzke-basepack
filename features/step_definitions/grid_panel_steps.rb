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
