When /^I expand combobox "([^"]*)"$/ do |combo_label|
  page.driver.browser.execute_script <<-JS
    var combo = Ext.ComponentMgr.all.filter('fieldLabel', '#{combo_label}').first();
    combo.onTriggerClick();
  JS

  When "I wait for the response from the server"
end

When /^I select "([^"]*)" from combobox "([^"]*)"$/ do |value, combo_label|
  page.driver.browser.execute_script <<-JS
    var combo = Ext.ComponentMgr.all.filter('fieldLabel', '#{combo_label}').first();
    var index = combo.getStore().find('name', '#{value}');
    combo.setValue(combo.getStore().getAt(index).get('id'));
  JS
end
