When /^I expand "([^"]*)"$/ do |arg1|
  page.driver.browser.execute_script <<-JS
    Ext.ComponentQuery.query('panel[title="#{arg1}"]')[0].expand();
  JS
end
