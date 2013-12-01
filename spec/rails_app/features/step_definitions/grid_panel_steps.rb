When /^I select first row in the grid$/ do
  page.driver.browser.execute_script <<-JS
    Ext.ComponentQuery.query('gridpanel')[0].getSelectionModel().select(0);
  JS
end

# This step can randomly cause problems, by selectAll being seemingly ignored; not used atm.
When /^I select all rows in the grid$/ do
  page.driver.browser.execute_script <<-JS
    var grid = Ext.ComponentQuery.query('gridpanel')[0];
    grid.getSelectionModel().selectAll();
  JS
end

Then /^the grid should show (\d+) records$/ do |arg1|
  page.driver.browser.execute_script(<<-JS).should == arg1.to_i
    var grid = Ext.ComponentQuery.query('gridpanel')[0];
    return grid.getStore().getCount();
  JS
end

When /^I edit row (\d+) of the grid with #{capture_fields}$/ do |rowIndex, fields|
  fields = parse_fields(fields)
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
    var grid = Ext.ComponentQuery.query('gridpanel')[0],
        filter;
    grid.filters.createFilters();
    filter = grid.filters.getFilter('#{column}');
    filter.setValue(#{value});
    filter.setActive(true);
  JS
  sleep 1
end

# E.g.: And I enable date filter on column "last_read_at" with value "after 04/25/2011" (this date should be in the US format)
When /^I enable date filter on column "([^"]*)" with value "([^"]*)"$/ do |column, value|
  operand, date = value.split
  page.driver.browser.execute_script <<-JS
    var grid = Ext.ComponentQuery.query('gridpanel')[0],
        filter, value;
    grid.filters.createFilters();
    filter = grid.filters.getFilter('#{column}');
    value = filter.getValue();
    value.#{operand} = new Date('#{date}'); // merge the new value with the current one
    filter.setValue(value);
    filter.setActive(true);
  JS
  sleep 1
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
    var grid    = Ext.ComponentQuery.query('gridpanel')[0],
        editor  = grid.getPlugin('celleditor');

    editor.startEditByPosition({ row:#{row.to_i-1}, column:grid.headerCt.items.findIndex('name', '#{field}') });
  JS

  sleep 0.5

  page.driver.browser.execute_script("Ext.ComponentQuery.query('netzkeremotecombo')[0].onTriggerClick();");
end

When /^I select "([^"]*)" in combobox "([^"]*)" in row (\d+) of the grid$/ do |value, field, row|
  page.driver.browser.execute_script <<-JS
    var grid   = Ext.ComponentQuery.query('gridpanel')[0],
        col    = Ext.ComponentQuery.query('gridcolumn[name="#{field}"]'),
        colId  = grid.headerCt.items.findIndex('name', '#{field}'),
        combo  = Ext.ComponentQuery.query('netzkeremotecombo')[0];

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

# When /^I (?:drag|move) "([^"]*)" column before "([^"]*)"$/ do |header1, header2|
#   # headers=[header1,header2].map {|s| s=s.gsub(/ /, '  ')}
#   # indexi =[0,1].map { |i| i=page.driver.browser.execute_script %Q(return Ext.ComponentQuery.query('gridcolumn[text="#{headers[i]}"]')[0].getIndex()) }
#   page.driver.browser.execute_script <<-JS
#     var i1 = Ext.ComponentQuery.query('gridcolumn[text="#{header1}"]')[0].getIndex();
#     var i2 = Ext.ComponentQuery.query('gridcolumn[text="#{header2}"]')[0].getIndex();
#     cmp = Ext.ComponentQuery.query('gridpanel')[0];
#     cmp.headerCt.moveHeader(i1+1, i2+1);
#   JS
#   step "I wait for response from server"
# end

# Then /^I should see columns in order: "([^"]*)", "([^"]*)", "([^"]*)"$/ do |header1, header2, header3|
#   headers=[header1,header2,header3].map {|s| s=s.gsub(/ /, '  ')}
#   page.driver.browser.execute_script(<<-JS).should be_true
#     return (Ext.ComponentQuery.query('gridcolumn[text="#{headers[0]}"]')[0].getIndex() == 0) &&
#            (Ext.ComponentQuery.query('gridcolumn[text="#{headers[1]}"]')[0].getIndex() == 1) &&
#            (Ext.ComponentQuery.query('gridcolumn[text="#{headers[2]}"]')[0].getIndex() == 2)
#   JS
# end

When /^I click on column "([^"]*)"$/ do |column|
  el_id = page.driver.browser.execute_script <<-JS
    return Ext.ComponentQuery.query('gridcolumn[text="#{column}"]')[0].id;
  JS

  find("##{el_id}").click
end

Then /^the grid should have records sorted by "([^"]*)"\s?(asc|desc)?$/ do |column, dir|
  dir ||= "asc"

  page.driver.browser.execute_script(<<-JS).should be_true
    var grid   = Ext.ComponentQuery.query('gridpanel')[0],
        column = Ext.ComponentQuery.query('gridcolumn[text="#{column}"]')[0],
        fieldName = column.name,
        columnValues = [];

    grid.getStore().each(function(r){
      var value = column.assoc ? r.get('meta').associationValues[fieldName] : r.get(fieldName);
      if (value) columnValues.#{dir == "asc" ? "push" : "unshift"}(value);
    });

    return (columnValues.length > 0) && (columnValues.toString() === Ext.Array.sort(columnValues).toString());
  JS
end

Then /^the grid's column "([^"]*)" should not be sortable$/ do |column_name|
  column = column_name.downcase.gsub(' ', '_')
  page.driver.browser.execute_script(<<-JS).should_not be_true
    var col = Ext.ComponentQuery.query('gridcolumn[name="#{column}"]')[0];
    return col.sortable;
  JS
end

Then /^the grid's column "([^"]*)" should not be editable$/ do |column_name|
  column = column_name.downcase.gsub(' ', '_')
  page.driver.browser.execute_script(<<-JS).should be_true
    var col = Ext.ComponentQuery.query('gridcolumn[name="#{column}"]')[0];
    return typeof col.getEditor() == 'undefined';
  JS
end

Then /^the grid should have (\d+) selected records$/ do |n|
  page.driver.browser.execute_script(<<-JS).should == n.to_i
    return Ext.ComponentQuery.query('gridpanel')[0].getSelectionModel().getSelection().length;
  JS
end

# TODO: move to Communitypack
# When /^I click the "([^"]*)" action icon$/ do |action_name|
#   find("img[data-qtip='#{action_name}']").click
# end
