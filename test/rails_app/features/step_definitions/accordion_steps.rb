When /^I expand "([^"]*)"$/ do |arg1|
  page.driver.browser.execute_script <<-JS
    var components = [];
    for (var cmp in Netzke.page) { components.push(cmp); }
    var accordion = Netzke.page[components[0]];
    var panelToExpand = accordion.items.find(function(i){return i.title == '#{arg1}';});
    panelToExpand.expand();
  JS
end
