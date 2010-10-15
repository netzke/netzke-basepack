Feature: Search
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: Search via Search window
    Given the following roles exist:
    | name |
    | admin |
    | superadmin |
    | user |
    
    And the following users exist:
    | first_name | last_name | role__name |
    | Paul | Bley | admin |
    | Dalai | Lama | user |
    | Taisha | Abelar | superadmin |
    | Florinda | Donner | admin |
    
    When I go to the UserGrid test page
    Then the grid should show 4 records
    
    And I press "Search"
    And I fill in "First name like:" with "ai"
    And I press "Search" within "#user_grid__search_panel"
    And I sleep 1 second
    Then the grid should show 2 records
    
    When I press "Search"
    And I fill in "Role name like:" with "adm"
    And I fill in "First name like:" with ""
    And I press "Search" within "#user_grid__search_panel"
    And I sleep 1 second
    Then the grid should show 3 records