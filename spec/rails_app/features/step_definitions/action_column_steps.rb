When /^I click icon "(.*?)"$/ do |action_name|
  find("img[data-qtip='#{action_name}']").click
end
