Feature: Grid panel
  In order to value
  As a role
  I want feature

@javascript
Scenario: BookGrid should correctly display data
  Given an author exists with first_name: "Vladimir", last_name: "Nabokov"
  And a book exists with author: that author, title: "Lolita", last_read_at: "2011-12-13 11:12:13", published_on: "2005-01-30"

  When I go to the BookGrid test page
  Then I should see "Nabokov, Vladimir"
  And I should see "12/13/2011 11:12:13"
  And I should see "01/30/2005"

@javascript
Scenario: Adding a record via "Add in form"
  Given I am on the UserGrid test page
  When I press "Add in form"
  Then I should see "Add User"
  When I fill in "First name:" with "Herman"
  And I fill in "Last name:" with "Hesse"
  And I press "OK"
  Then I should see "Herman"
  And I should see "Hesse"
  And a user should exist with first_name: "Herman", last_name: "Hesse"

@javascript
Scenario: Updating a record via "Edit in form"
  Given a user exists with first_name: "Carlos", last_name: "Castaneda"
  When I go to the UserGrid test page
  And I wait for response from server
  And I select first row in the grid
  And I press "Edit in form"
  And I fill in "First name:" with "Maxim"
  And I fill in "Last name:" with "Osminogov"
  And I press "OK"
  And I wait for response from server
  Then I should see "Maxim"
  And I should see "Osminogov"
  And a user should not exist with first_name: "Carlos"

@javascript
Scenario: Deleting a record
  Given a user exists with first_name: "Anton", last_name: "Chekhov"
  When I go to the UserGrid test page
  And I wait for response from server
  And I select first row in the grid
  And I press button with text "Delete"
  Then I should see "Are you sure?" within ".x-window"
  When I press button with text "Yes"
  Then I should see "Deleted 1 record(s)"
  Then a user should not exist with first_name: "Anton"

@javascript
Scenario: Try deleting an undeletable record
  Given a user exists with first_name: "Admin", last_name: "Admin"
  When I go to the UserGrid test page
  And I select all rows in the grid
  And I press "Delete"
  Then I should see "Are you sure?"
  When I press "Yes"
  Then I should see "Can't delete Admin User"
  Then a user should exist with first_name: "Admin"

@javascript
Scenario: Multi-editing records
  Given a user exists with first_name: "Carlos", last_name: "Castaneda"
  And a user exists with first_name: "Herman", last_name: "Hesse"
  When I go to the UserGrid test page
  And I wait for response from server
  And I select all rows in the grid
  And I press "Edit in form"
  And I wait for response from server
  And I fill in "First name:" with "Maxim"
  And I press "OK"
  And I wait for response from server
  Then the following users should exist:
  | first_name | last_name |
  | Maxim | Castaneda |
  | Maxim | Hesse |
  And I should not see window
  But a user should not exist with first_name: "Carlos"

@javascript
Scenario: Filling out association column with association's virtual method
  Given an author exists with first_name: "Vladimir", last_name: "Nabokov"
  And a book exists with title: "Lolita", author: that author
  When I go to the BookGrid test page
  Then I should see "Nabokov, Vladimir"
  And I should see "Lolita"

@javascript
Scenario: Grid with strong_default_attrs
  Given an author exists with first_name: "Vladimir", last_name: "Nabokov"
  And a book exists with title: "Lolita", author: that author
  And a book exists with title: "Unknown"
  When I go to the BooksBoundToAuthor test page
  And I press "Add in form"
  And I fill in "Title:" with "The Luzhin Defence"
  And I press "OK"
  And I should see "The Luzhin Defence"
  And I should see "Lolita"
  But I should not see "Unknown"

@javascript
Scenario: Grid with columns with default values
  Given an author exists with last_name: "Nabokov"
  And I am on the BookGridWithDefaultValues test page
  When I press "Add"
  Then I should see "Nabokov"
  And I press "Apply"
  And I wait for response from server
  Then a book should exist with title: "Lolita", exemplars: 100, digitized: true, author: that author

  When I press "Add in form"
  And I press "OK"
  And I wait for response from server
  Then 2 books should exist with title: "Lolita", exemplars: 100, digitized: true, author: that author

@javascript
Scenario: Inline editing
  Given a book exists with title: "Magus", exemplars: 100
  When I go to the BookGrid test page
  And I wait for response from server
  And I edit row 1 of the grid with title: "Collector", exemplars: 200
  And I press "Apply"
  And I wait for response from server
  Then the grid should have 0 modified records
  And a book should exist with title: "Collector", exemplars: 200
  But a book should not exist with title: "Magus"

@javascript
Scenario: Inline editing of association
  Given an author exists with first_name: "Vladimir", last_name: "Nabokov"
  And a book exists with title: "Lolita", author: that author
  And an author exists with first_name: "Herman", last_name: "Hesse"
  When I go to the BookGrid test page
  And I wait for response from server
  And I expand combobox "author__name" in row 1 of the grid
  And I wait for response from server
  And I select "Hesse, Herman" in combobox "author__name" in row 1 of the grid
  And I edit row 1 of the grid with title: "Demian"
  And I stop editing the grid
  Then I should see "Hesse, Herman" within "#book_grid"

  When I press "Apply"
  And I wait for response from server
  Then a book should exist with title: "Demian", author: that author
  But a book should not exist with title: "Lolita"

@javascript
Scenario: Inline adding of records
  Given an author: "Nabokov" exists with first_name: "Vladimir", last_name: "Nabokov"
  And an author: "Hesse" exists with first_name: "Herman", last_name: "Hesse"

  When I go to the BookGrid test page
  And I press "Add"
  And I expand combobox "author__name" in row 1 of the grid
  And I wait for response from server
  And I select "Hesse, Herman" in combobox "author__name" in row 1 of the grid
  And I edit row 1 of the grid with title: "Demian"
  And I stop editing the grid

  And I press "Add"
  And I expand combobox "author__name" in row 2 of the grid
  And I wait for response from server
  And I select "Nabokov, Vladimir" in combobox "author__name" in row 2 of the grid
  And I edit row 2 of the grid with title: "Lolita"
  And I stop editing the grid

  And I press "Apply"
  And I wait for response from server
  Then a book should exist with title: "Lolita", author: author "Nabokov"
  And a book should exist with title: "Demian", author: author "Hesse"

@javascript
Scenario: Inline adding of records in Grid with default values
  Given an author: "Nabokov" exists with first_name: "Vladimir", last_name: "Nabokov"
  And an author: "Hesse" exists with first_name: "Herman", last_name: "Hesse"

  When I go to the BookGridWithDefaultValues test page
  And I press "Add"
  And I expand combobox "author__last_name" in row 1 of the grid
  And I wait for response from server
  And I select "Hesse" in combobox "author__last_name" in row 1 of the grid
  And I edit row 1 of the grid with title: "Demian"

  And I stop editing the grid
  And I press "Apply"
  And I wait for response from server
  Then a book should exist with title: "Demian", author: author "Hesse"

@javascript
Scenario: Renderers for association columns should take effect
  Given an author exists with first_name: "Vladimir", last_name: "Nabokov"
  And a book exists with title: "Lolita", author: that author
  When I go to the BookGridWithCustomColumns test page
  Then I should see "NABOKOV"
  And I should see "*Vladimir*"

@javascript
Scenario: Reloading grid data
  Given a book exists with title: "Magus"
  When I go to the BookGrid test page
  And I reload the grid
  And I reload the grid
  Then I should not see "Internal Server Error"

@javascript
Scenario: Advanced search window should be hidable after loading grid panel dynamically second time
  Given I am on the BookGridLoader test page
  When I press "Load one"
  And I wait for response from server
  And I press "Search"
  And I press "Cancel"

  When I press "Load two"
  And I wait for response from server

  When I press "Load one"
  And I wait for response from server

  And I press "Search" within "#book_grid_loader__book_grid_one"
  And I wait for response from server
  And I press "Cancel" within "#book_grid_loader__book_grid_one__search_window"
  Then the "book_grid_loader__book_grid_one__search_window" component should be hidden

@javascript
Scenario: Column order should be saved across page reloads
  Given I am on the BookGridWithPersistence test page
  When I drag "Digitized" column before "Title"
  And I wait for response from server
  And I go to the BookGridWithPersistence test page
  Then I should see columns in order: "Digitized", "Title", "Exemplars"
  When I drag "Digitized" column before "Exemplars"
  And I wait for response from server
  And I go to the BookGridWithPersistence test page
  Then I should see columns in order: "Title", "Digitized", "Exemplars"

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
  And I should see "Nabokov, Vladimir"

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
#   And I press "Yes"
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
Scenario: Editing in grid with mass-assignment security
  # exemplars and author_id are protected attributes, not possible to change
  Given an author exists with first_name: "Vladimir", last_name: "Nabokov"
  And a book exists with title: "Lolita", author: that author, exemplars: 100
  And an author exists with first_name: "Herman", last_name: "Hesse"
  When I go to the BookGridWithMassAssignmentSecurity test page
  And I wait for response from server
  And I expand combobox "author__name" in row 1 of the grid
  And I wait for response from server
  And I select "Hesse, Herman" in combobox "author__name" in row 1 of the grid
  And I edit row 1 of the grid with title: "Demian", exemplars: 200
  And I stop editing the grid
  And I press "Apply"
  And I wait for response from server
  Then a book should not exist with author: that author
  And a book should not exist with exemplars: 200
  But a book should exist with title: "Demian", exemplars: 100

@javascript
Scenario: Scoping out grid records
  Given an author exists with first_name: "Vladimir", last_name: "Nabokov"
  And a book exists with title: "Lolita", author: that author
  And a book exists with title: "Louzhin Defence", author: that author
  And an author exists with first_name: "Herman", last_name: "Hesse"
  And a book exists with title: "Demian", author: that author
  When I go to the BookGridWithScope test page
  And I wait for response from server
  Then the grid should show 2 records

@javascript
Scenario: Inline grid data
    Given a book exists with title: "Man for himself"
    When I go to the GridWithInlineData test page
    Then I should see "Man for himself"
