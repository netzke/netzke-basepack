When /^I select first row in the grid$/ do
  page.driver.browser.execute_script <<-JS
    Ext.ComponentQuery.query('gridpanel')[0].getSelectionModel().select(0);
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
    return Ext.ComponentQuery.query('gridpanel')[0].getStore().getUpdatedRecords().length;
  JS
end

When /^I enable filter on column "([^"]*)" with value "([^"]*)"$/ do |column, value|
  page.driver.browser.execute_script <<-JS
    var components = [];
    for (var cmp in Netzke.page) { components.push(cmp); }
    var grid = Netzke.page[components[0]];
    var filter = grid.filters.getFilter('#{column}');
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

When /^I expand combobox "([^"]*)" in row (\d+) of the grid$/ do |field, row|
  page.driver.browser.execute_script <<-JS
    var grid = Ext.ComponentQuery.query('gridpanel')[0];
    var editor = grid.getPlugin('celleditor');
    editor.startEditByPosition({ row:#{row.to_i-1}, column:grid.headerCt.items.findIndex('name', '#{field}') });
  JS
  # HACK: test fails w\o this stupid thing
  sleep 1

  page.driver.browser.execute_script("Ext.ComponentQuery.query('netzkeremotecombo')[0].onTriggerClick();");
end

When /^I select "([^"]*)" in combobox "([^"]*)" in row (\d+) of the grid$/ do |value, field, row|
  page.driver.browser.execute_script <<-JS
    var grid   = Ext.ComponentQuery.query('gridpanel')[0];
    var col    = Ext.ComponentQuery.query('gridcolumn[name="#{field}"]');
    var colId  = grid.headerCt.items.findIndex('name', '#{field}');
    var combo = Ext.ComponentQuery.query('netzkeremotecombo')[0];


    combo.setValue( combo.findRecordByDisplay('#{value}') );
    combo.onTriggerClick();
  JS
end

When /^I stop editing the grid$/ do
  page.driver.browser.execute_script <<-JS
    var p;
    (p = Ext.ComponentQuery.query('gridpanel')[0].getPlugin('celleditor')) && p.completeEdit();
  JS
end

When /^I reload the grid$/ do
  page.driver.browser.execute_script <<-JS
    var components = [];
    for (var cmp in Netzke.page) { components.push(cmp); }
    var grid = Netzke.page[components[0]];
    grid.getStore().load();
  JS
end

When /^I (?:drag|move) "([^"]*)" column before "([^"]*)"$/ do |header1, header2|
  headers=[header1,header2].map {|s| s=s.gsub(/ /, '  ')}
  indexi =[0,1].map { |i| i=page.driver.browser.execute_script %Q(return Ext.ComponentQuery.query('gridcolumn[label="#{headers[i]}"]')[0].getIndex()) }
  page.driver.browser.execute_script <<-JS
    cmp = Ext.ComponentQuery.query('gridpanel')[0];
    cmp.onColumnMove(null, null, #{indexi[0]}, #{indexi[1]});
  JS
end

Then /^I should see columns in order: "([^"]*)", "([^"]*)", "([^"]*)"$/ do |header1, header2, header3|
  headers=[header1,header2,header3].map {|s| s=s.gsub(/ /, '  ')}
  page.driver.browser.execute_script(<<-JS).should be_true
    return (Ext.ComponentQuery.query('gridcolumn[label="#{headers[0]}"]')[0].getIndex() == 1) &&
           (Ext.ComponentQuery.query('gridcolumn[label="#{headers[1]}"]')[0].getIndex() == 2) &&
           (Ext.ComponentQuery.query('gridcolumn[label="#{headers[2]}"]')[0].getIndex() == 3)
  JS
end

