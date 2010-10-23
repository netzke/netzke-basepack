Feature: Accordion panel
  In order to value
  As a role
  I want feature

@javascript
Scenario: Lazy loading of a component into a panel when the latter gets expanded
  Given I am on the SimpleAccordion test page
  When I expand "Panel Two"
  Then I should see "Original HTML"
  When I press "Update html"
  Then I should see "Update for Panel Two" 



