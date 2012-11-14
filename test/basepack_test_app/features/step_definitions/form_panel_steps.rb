When /^I expand combobox "([^"]*)"$/ do |combo_label|
  page.driver.browser.execute_script <<-JS
    var combo = Ext.ComponentQuery.query("combobox[fieldLabel='#{combo_label}']")[0];
    combo = combo || Ext.ComponentQuery.query("combobox[name='#{combo_label}']")[0];
    combo.onTriggerClick();
  JS

  step "I wait for response from server"
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
      var field = form.findField(fieldName);

      if (field.getXType() == 'xdatetime') {
        // Treat xdatetime specially
        var oldValue = field.getValue();
        field.setValue(values[fieldName]);
        return oldValue == field.getValue();
      } else {
        return (field.getValue() == values[fieldName] || field.getRawValue() == values[fieldName]);
      }
    }
    return true;
  JS
end

Then /^I fill in Ext field "([^"]*)" with "([^"]*)"$/ do |field_label, value|
  page.driver.browser.execute_script <<-JS
    var field = Ext.ComponentQuery.query("[fieldLabel='#{field_label}']")[0];
    field.setValue("#{value}");
  JS
end
