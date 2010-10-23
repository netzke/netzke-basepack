Feature: Basic application
  In order to value
  As a role
  I want feature

@javascript
Scenario: BasicApp should load its components dynamically
  Given I am on the SimpleBasicApp test page
  When I press "Simple accordion"
  Then I should see "Simple basic app simple accordion"


