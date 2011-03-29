Feature: Basic application
  In order to value
  As a role
  I want feature

@javascript
Scenario: SimpleApp should load its components dynamically
  Given I am on the SomeSimpleApp test page
  When I press "Simple accordion"
  Then I should see "Some simple app simple accordion"
