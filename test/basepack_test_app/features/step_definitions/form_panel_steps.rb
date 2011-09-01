When /^I expand combobox "([^"]*)"$/ do |combo_label|
  page.driver.browser.execute_script <<-JS
    var combo = Ext.ComponentQuery.query("combobox[fieldLabel='#{combo_label}']")[0];
    combo = combo || Ext.ComponentQuery.query("combobox[name='#{combo_label}']")[0];
    combo.onTriggerClick();
  JS

  When "I wait for the response from the server"
end

When /^I select "([^"]*)" from combobox "([^"]*)"$/ do |value, combo_label|
  page.driver.browser.execute_script <<-JS
    var combo = Ext.ComponentQuery.query("combobox[fieldLabel='#{combo_label}']")[0];
    combo = combo || Ext.ComponentQuery.query("combobox[name='#{combo_label}']")[0];
    var rec = combo.findRecordByDisplay('#{value}');
    combo.select(rec);
    combo.fireEvent('select', combo, rec );
  JS
end

Then /the form should show #{capture_fields}$/ do |fields|
  page.driver.browser.execute_script(<<-JS).should == true
    var form = Ext.ComponentQuery.query('form')[0].getForm();
    var values = {#{fields}};
    for (var fieldName in values) {
      if ((form.findField(fieldName).getValue() != values[fieldName]) && (form.findField(fieldName).getRawValue() != values[fieldName])) return false;
    }
    return true;
  JS
end
