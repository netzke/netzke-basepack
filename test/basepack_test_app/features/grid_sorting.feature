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
    And I sleep 1 second
    Then the grid should have records sorted by "Title"

    When I click on column "Title"
    And I sleep 1 second
    Then the grid should have records sorted by "Title" desc

  @javascript
  Scenario: Sorting on association column
    Given an author exists with first_name: "Herman"
    And a book exists with title: "Damian", author: that author
    And an author exists with first_name: "Carlos"
    And a book exists with title: "Journey", author: that author
    And an author exists with first_name: "John"
    And a book exists with title: "Magus", author: that author

    When I go to the BookGridWithCustomColumns test page
    And I click on column "Author  first name"
    And I sleep 1 second
    Then the grid should have records sorted by "Author  first name"

    And I click on column "Author  first name"
    And I sleep 1 second
    Then the grid should have records sorted by "Author  first name" desc
