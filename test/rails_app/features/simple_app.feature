Feature: Basic application
  In order to value
  As a role
  I want feature

@javascript
Scenario: SimpleApp should load its components dynamically
  Given I am on the SomeSimpleApp test page
  When I press "Simple accordion"
  Then I should see "Some simple app simple accordion"
  # TODO: there's a problem with dynamic loading of the grid: "event is undefined" as we try to load something AFTER loading grid
  # When I press "User grid"
  # Then I should see "Users"
  When I press "Simple tab panel"
  Then I should see "Some simple app simple tab panel"