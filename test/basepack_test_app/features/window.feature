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

@javascript
Scenario: Window with persistence should remember its size and position
  Given I am on the WindowComponentLoader test page
  When I press "Load window"
  And I wait for response from server
  And active window position must be 100,80
  Then active window size must be 300,200

  When I move active window to 50,40
  And I resize active window to 150,100
  And I wait for response from server

  And I go to the WindowComponentLoader test page
  When I press "Load window"
  Then active window position must be 50,40
  And active window size must be 150,100
