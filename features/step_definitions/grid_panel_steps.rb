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
