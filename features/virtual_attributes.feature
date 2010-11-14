Feature: Window component loader
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: Columns and fields with custom setter/getter methods should work as expected
    Given an author exists with first_name: "Victor"
    And a book exists with title: "Lolita", exemplars: "5", author: that author
    And I am on the BookGridWithVirtualAttributes test page
    Then I should see "Victor"
    And I should see "YES"

    When I select first row in the grid
    And I press "Edit in form"
    And I fill in "Author first name" with "Vladimir"
    And I fill in "Exemplars" with "3"
    And I press "OK"
    Then I should see "Vladimir"
    And I should see "NO"
