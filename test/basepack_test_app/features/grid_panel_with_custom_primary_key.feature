Feature: Grid panel with custom primary key
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: Inline editing
    Given a book_with_custom_primary_key exists with title: "Book you are to write"
    When I go to the BookWithCustomPrimaryKeyGrid test page
    And I edit row 1 of the grid with title: "My fight club"
    And I press "Apply"
    And I wait for the response from the server
    Then the grid should have 0 modified records
    And a book_with_custom_primary_key should exist with title: "My fight club"
    But a book should not exist with title: "Book you are to write"
