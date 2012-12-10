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

When /^I wait for response from server$/ do
  page.wait_until{ page.driver.browser.execute_script("return !Netzke.ajaxIsLoading()") }
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
  step %Q{I should see "#{text}"}
  # Not working, as it checks the initial text property, not the actual one
  # page.driver.browser.execute_script(<<-JS).should == true
  #   Ext.ComponentQuery.query('pagingtoolbar')[0].query('tbtext[text="#{text}"]').length >= 1
  # JS
end

When /^I resize the ([^"]*) region to the size of (\d+)$/ do |region, size|
  page.driver.browser.execute_script(<<-JS)
    for (var prop in Netzke.page) {
      var panel = Netzke.page[prop];
      break;
    }
    var region = panel.down('panel[region="#{region}"]');

    region.setSize({"#{["south", "north"].include?(region) ? "height" : "width"}": #{size}});
  JS
end

Then /^the ([^"]*) region should have size of (\d+)$/ do |region, size|
  size_property = [:west, :east].include?(region.to_sym) ? :Width : :Height

  page.driver.browser.execute_script(<<-JS).should == size.to_i
    for (var prop in Netzke.page) {
      var panel = Netzke.page[prop];
      break;
    }
    var region = panel.down('panel[region="#{region}"]');

    return region.get#{size_property}();
  JS
end

When /^I collapse the ([^"]*) region$/ do |region|
  page.driver.browser.execute_script(<<-JS)
    for (var prop in Netzke.page) {
      var panel = Netzke.page[prop];
      break;
    }
    var region = panel.down('panel[region="#{region}"]')
    region.on('collapse', function(r){r.doneCollapsing = true});

    region.collapse();
  JS

  wait_until do
    page.driver.browser.execute_script(<<-JS)
      for (var prop in Netzke.page) {
        var panel = Netzke.page[prop];
        break;
      }
      var region = panel.down('panel[region="#{region}"]')

      return region.doneCollapsing;
    JS
  end
end

Then /^the ([^"]*) region should be (expanded|collapsed)$/ do |region, state|
  page.driver.browser.execute_script(<<-JS).should state == "collapsed" ? be_true : be_false
    for (var prop in Netzke.page) {
      var panel = Netzke.page[prop];
      break;
    }
    var region = panel.down('panel[region="#{region}"]');

    return !!region.collapsed;
  JS
end

When /^I expand the ([^"]*) region$/ do |region|
  page.driver.browser.execute_script(<<-JS)
    for (var prop in Netzke.page) {
      var panel = Netzke.page[prop];
      break;
    }
    var region = panel.down('panel[region="#{region}"]')
    region.on('expand', function(r){r.doneExpanding = true});

    region.expand();
  JS
  wait_until do
    page.driver.browser.execute_script(<<-JS)
      for (var prop in Netzke.page) {
        var panel = Netzke.page[prop];
        break;
      }
      var region = panel.down('panel[region="#{region}"]')
      return region.doneExpanding;
    JS
  end
end

# Because sometimes "I press 'Text'" does not work due to some reason...
When /^I press button with text "(.*?)"$/ do |text|
  click_button page.driver.browser.execute_script(<<-JS) + '-btnEl'
    var button = Ext.ComponentQuery.query("button[text='#{text}']")[0];
    return button.id;
  JS
end

Then /^I should not see window$/ do
  page.driver.browser.execute_script(<<-JS).should == true
    var out = true;
    Ext.each(Ext.ComponentQuery.query('window'), function(w){
      if (w.isVisible()) {
        out = false;
        return false;
      }
    });
    return out;
  JS
end

Then /^active tab should have button "(.*?)"$/ do |text|
  page.driver.browser.execute_script(<<-JS).should == true
    var tp = Ext.ComponentQuery.query('tabpanel')[0],
        at = tp.getActiveTab();
    return !!at.down('button[text="#{text}"]');
  JS
end
