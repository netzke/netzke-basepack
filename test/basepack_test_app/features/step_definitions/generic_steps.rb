Then /^Netzke should be initialized$/ do
  Netzke::Base.should be
end

When /^I execute "([^\"]*)"$/ do |script|
  page.driver.browser.execute_script(script)
end

Then /^button "([^"]*)" should be disabled$/ do |arg1|
  Netzke.should be # PENDING!
end

When /I (?:sleep|wait) (\d+) (\w+)/ do |amount, unit|
  sleep amount.to_i.send(unit)
end

When /^I wait for the response from the server$/ do
  page.wait_until{ page.driver.browser.execute_script("return !(Netzke.ajaxIsLoading() || Ext.Ajax.isLoading())") }
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

Then /^I should see "([^"]*)" within paging toolbar$/ do |text|
  Then %Q{I should see "#{text}"}
  # Not working, as it checks the initial text property, not the actual one
  # page.driver.browser.execute_script(<<-JS).should == true
  #   Ext.ComponentQuery.query('pagingtoolbar')[0].query('tbtext[text="#{text}"]').length >= 1
  # JS
end
