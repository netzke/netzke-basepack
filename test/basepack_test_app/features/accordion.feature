Feature: Accordion panel
  In order to value
  As a role
  I want feature

@javascript
Scenario: Lazy loading of a component into a panel when the latter gets expanded
  When I go to the SomeAccordion test page
  Then expanded panel should have button "Update html"
  When I expand "Panel Two"
  And I sleep 1 second
  Then expanded panel should have button "Update html"
  When I press "Update html"
  Then I should see "Update for Panel Two"
