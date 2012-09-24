Feature: Persistent regions
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: A panel with persistent regions should store its region sizes
    Given I am on the PanelWithPersistentRegions test page
    When I resize the west region to the size of 300
    And I wait for the response from the server
    And I go to the PanelWithPersistentRegions test page
    Then the west region should have size of 300
    When I resize the east region to the size of 300
    And I wait for the response from the server
    And I go to the PanelWithPersistentRegions test page
    Then the east region should have size of 300

  @javascript
  Scenario: A panel with persistent regions should store its region collapse status
    Given I am on the PanelWithPersistentRegions test page
    When I collapse the south region
    And I wait for the response from the server
    And I go to the PanelWithPersistentRegions test page
    Then the south region should be collapsed
    When I expand the south region
    And I wait for the response from the server
    And I go to the PanelWithPersistentRegions test page
    Then the south region should be expanded
