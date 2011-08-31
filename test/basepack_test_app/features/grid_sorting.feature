Feature: Grid sorting
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: Sorting on regular column
    Given the following books exist:
    | title   |
    | Belief  |
    | Cosmos  |
    | Avatar  |

    When I go to the BookGrid test page
    And I click on column "Title"
    Then the grid should have records sorted by "title"

    When I click on column "Title"
    Then the grid should have records sorted by "title" desc
