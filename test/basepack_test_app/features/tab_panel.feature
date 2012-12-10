Feature: Tab panel
  In order to value
  As a role
  I want feature

@javascript
Scenario: Lazy loading of a component into a tab when the latter gets open
  When I go to the SomeTabPanel test page
  Then active tab should have button "Update html"
  When I press "Panel Two"
  Then active tab should have button "Update html"
  When I press "Update html"
  Then I should see "Update for Panel Two"
