When /^(?:|I )check ext checkbox "([^"]*)"$/ do |field|
  page.driver.browser.execute_script <<-JS
    var checkbox = Ext.ComponentQuery.query("checkboxfield[fieldLabel='#{field}']")[0];
    checkbox = checkbox || Ext.ComponentQuery.query("checkboxfield[boxLabel='#{field}']")[0];
    checkbox.setValue(true);
  JS
end

Then /^ext "([^"]*)" checkbox should(| not) be checked$/ do |name, arg|
  page.driver.browser.execute_script(<<-JS).should == arg.eql?("")
    var checkbox = Ext.ComponentQuery.query('checkboxfield[boxLabel="#{name}"]')[0];
    checkbox = checkbox || Ext.ComponentQuery.query('checkboxfield[fieldLabel="#{name}"]')[0];

    return checkbox.getValue();
  JS
end
