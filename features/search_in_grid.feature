Feature: Search
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: Search via Search window
    Given the following roles exist:
    | id | name       |
    | 1  | admin      |
    | 2  | superadmin |
    | 3  | user       |

    And the following users exist:
    | first_name | last_name | role_id |
    | Paul       | Bley      | 1       |
    | Dalai      | Lama      | 3       |
    | Taisha     | Abelar    | 2       |
    | Florinda   | Donner    | 1       |

    When I go to the UserGrid test page
    Then the grid should show 4 records

    When I press "Search"
    And I fill in "first_name_value" with "ai"
    And I press "Search" within "#user_grid__search_form"
    And I wait for the response from the server
    Then the grid should show 2 records

    # Search on association column not supported yet
    # When I press "Search"
    # And I fill in "Role name like:" with "adm"
    # And I fill in "First name like:" with ""
    # And I press "Search" within "#user_grid__search_form"
    # And I sleep 1 second
    # Then the grid should show 3 records