Feature: Persistent regions
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: A panel with persistent regions should store its region sizes
    When I go to the PanelWithPersistentRegions test page
    Then the west region should have size of 100
    And the south region should have size of 100

    When I resize the west region to the size of 300
    And I resize the south region to the size of 200

    And I wait for response from server
    And I go to the PanelWithPersistentRegions test page
    Then the west region should have size of 300
    And the south region should have size of 200

  @javascript
  Scenario: A panel with persistent regions should store its region collapse status
    Given I am on the PanelWithPersistentRegions test page
    When I collapse the south region
    And I wait for response from server
    And I go to the PanelWithPersistentRegions test page
    Then the south region should be collapsed
    When I expand the south region
    And I wait for response from server
    And I go to the PanelWithPersistentRegions test page
    Then the south region should be expanded
