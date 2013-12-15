Feature: Grid panel
  In order to value
  As a role
  I want feature

@javascript
Scenario: Grid with strong_default_attrs
  Given an author exists with first_name: "Vladimir", last_name: "Nabokov"
  And a book exists with title: "Lolita", author: that author
  And a book exists with title: "Unknown"
  When I go to the BooksBoundToAuthor test page
  And I click "Add in form"
  And I fill in "Title:" with "The Luzhin Defence"
  And I click "OK"
  And I should see "The Luzhin Defence"
  And I should see "Lolita"
  But I should not see "Unknown"

@javascript
Scenario: Renderers for association columns should take effect
  Given an author exists with first_name: "Vladimir", last_name: "Nabokov"
  And a book exists with title: "Lolita", author: that author
  When I go to the Grid::CustomColumns test page
  Then I should see "NABOKOV"
  And I should see "*Vladimir*"

@javascript
Scenario: Reloading grid remembers selection
  Given a book exists with title: "Magus"
  And another book exists with title: "Lolita"
  When I go to the BookGrid test page
  And I wait for response from server
  And I select first row in the grid
  Then the grid should have 1 selected records
  When I reload the grid
  And I wait for response from server
  And I wait 1 second
  Then the grid should have 1 selected records

# @javascript
# Scenario: Column order should be saved across page reloads
#   Given I am on the BookGridWithPersistence test page
#   When I drag "Digitized" column before "Title"
#   And I wait for response from server
#   And I go to the BookGridWithPersistence test page
#   Then I should see columns in order: "Digitized", "Title", "Exemplars"

#   When I drag "Digitized" column before "Exemplars"
#   And I wait for response from server
#   And I go to the BookGridWithPersistence test page
#   Then I should see columns in order: "Title", "Digitized", "Exemplars"

@javascript
Scenario: I must see total records value
  Given the following books exist:
  | title               |
  | Journey to Ixtlan   |
  | Lolita              |
  | Getting Things Done |
  | Magus               |

  When I go to the BookGridWithPaging test page
  Then I should see "of 2" within paging toolbar

@javascript
Scenario: Grid with overridden columns
  Given an author exists with first_name: "Vladimir", last_name: "Nabokov"
  And a book exists with title: "Lolita", author: that author
  When I go to the BookGridWithOverriddenColumns test page
  Then I should see "LOLITA"
  And I should see "Vladimir Nabokov"

@javascript
  Scenario: Virtual attributes should not be sortable
    Given a book exists with title: "Some Title"
    When I go to the BookGridWithVirtualAttributes test page
    Then the grid's column "In abundance" should not be sortable

@javascript
  Scenario: Virtual attributes should not be editable
    Given a book exists with title: "Some Title"
    When I go to the BookGridWithVirtualAttributes test page
    Then the grid's column "In abundance" should not be editable

# TODO: Action column code has been moved to Communitypack, move the tests
# @javascript
# Scenario: Delete record via an column action
#   Given a book exists with title: "Some Title"
#   When I go to the BookGridWithColumnActions test page
#   And I click the "Delete row" action icon
#   And I click "Yes"
#   Then I should see "Deleted 1 record(s)"
#   And a book should not exist with title: "Some Title"

@javascript
Scenario: Pagination in grid panel
  Given the following books exist:
  | title               |
  | Journey to Ixtlan   |
  | Lolita              |
  | Getting Things Done |
  | Magus               |
  When I go to the BookGridWithPaging test page
  Then I should see "Journey to Ixtlan"
  And I should see "Lolita"
  But I should not see "Getting Things Done"
  And the grid should show 2 records

  When I go forward one page
  And  I wait for response from server
  Then I should see "Getting Things Done"
  And I should see "Magus"

@javascript
Scenario: Hidden columns
    When I go to the BookGridWithExcludedColumns test page
    Then I should not see "Notes"
    And I should not see "Exemplars"

@javascript
Scenario: Scoping out grid records
  Given an author exists with first_name: "Vladimir", last_name: "Nabokov"
  And a book exists with title: "Lolita", author: that author
  And a book exists with title: "Louzhin Defence", author: that author
  And an author exists with first_name: "Herman", last_name: "Hesse"
  And a book exists with title: "Demian", author: that author
  When I go to the ScopedGrid test page
  And I wait for response from server
  Then the grid should show 2 records

@javascript
Scenario: Inline grid data
    Given a book exists with title: "Man for himself"
    When I go to the GridWithInlineData test page
    Then I should see "Man for himself"
