Then /^Netzke should be initialized$/ do
  Netzke::Base.should be
end

When /^I execute "([^\"]*)"$/ do |script|
  page.driver.browser.execute_script(script)
end

Then /^button "([^"]*)" should be disabled$/ do |arg1|
  Netzke.should be # PENDING!
end

When /I sleep|wait (\d+) seconds?/ do |arg1|
  sleep arg1.to_i
end

When /^I wait for the response from the server$/ do
  # HACK: Ext.Ajax.isLoading() without parameter is broken, so he step always returns immediately
  # applying temporary fix
  sleep(5);
  page.wait_until{ page.driver.browser.execute_script("return !Ext.Ajax.isLoading();") }
end

When /^I go forward one page$/ do
  page.driver.browser.execute_script(<<-JS)
    var toolbar = Ext.ComponentQuery.query('pagingtoolbar')[0];
    toolbar.moveNext();
  JS
  page.wait_until{ page.driver.browser.execute_script("return !Ext.Ajax.isLoading();") }
end

Then /^the "([^"]*)" component should be hidden$/ do |id|
  page.driver.browser.execute_script(<<-JS).should be_false
    var cmp = Ext.ComponentMgr.get("#{id}");
    return cmp.isVisible();
  JS
end
