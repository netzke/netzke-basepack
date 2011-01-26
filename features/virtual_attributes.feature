Feature: Window component loader
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: Creating an author on the fly with BookGridWithVirtualAttributes
    Given an author exists with first_name: "Victor"
    And a book exists with author: that author, title: "Lolita"
    And I am on the BookGridWithVirtualAttributes test page
    Then I should see "Victor"

    When I edit row 1 of the grid with author__first_name: "Vladimir"
    And I press "Apply"
    And I wait for the response from the server
    Then I should see "Vladimir"
