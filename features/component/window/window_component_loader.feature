Feature: Window component loader
  In order to value
  As a role
  I want feature

@javascript
Scenario: Loading a Window Component dynamically
  Given I am on the WindowComponentLoader test page
  Then I should not see "Some Window Component"
  When I press "Load window"
  Then I should see "Some Window Component"
