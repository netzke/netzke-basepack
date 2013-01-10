Feature: Grid with action column
  In order to value
  As a role
  I want feature

@javascript
Scenario: Delete a record via pressing the delete icon
  Given a book exists with title: "Title 1"
  And a book exists with title: "Title 2"
  And I am on the GridWithActionColumn test page
  Then the grid should show 2 records
  When I click icon "Delete row"
  And I press "Yes"
  And I wait for response from server
  Then the grid should show 1 records
