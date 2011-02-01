When /^I expand combobox "([^"]*)"$/ do |combo_label|
  page.driver.browser.execute_script <<-JS
    var combo = Ext.ComponentMgr.all.filter('fieldLabel', '#{combo_label}').first();
    combo = combo || Ext.ComponentMgr.all.filter('name', '#{combo_label}').first();
    combo.onTriggerClick();
  JS

  When "I wait for the response from the server"
end

When /^I select "([^"]*)" from combobox "([^"]*)"$/ do |value, combo_label|
  page.driver.browser.execute_script <<-JS
    var combo = Ext.ComponentMgr.all.filter('fieldLabel', '#{combo_label}').first();
    combo = combo || Ext.ComponentMgr.all.filter('name', '#{combo_label}').first();
    var index = combo.getStore().find('field2', '#{value}');
    combo.setValue(combo.getStore().getAt(index).get('field1'));
  JS
end

Then /the form should show #{capture_fields}$/ do |fields|
  fields = ActiveSupport::JSON.decode("{#{fields}}")
  page.driver.browser.execute_script(<<-JS).should == true
    var components = [];
    for (var cmp in Netzke.page) { components.push(cmp); }
    var form = Netzke.page[components[0]].getForm();
    var result = true;
    var values = #{fields.to_json};
    for (var fieldName in values) {
      result = form.findField(fieldName).getValue() === values[fieldName];
      return result;
    }
    return result;
  JS
end