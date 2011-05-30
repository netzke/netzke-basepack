Feature: Grid panel
  In order to value
  As a role
  I want feature

Scenario: UserGrid should render properly
  Given a user exists with first_name: "Carlos", last_name: "Castaneda"
  And a user exists with first_name: "Taisha", last_name: "Abelar"
  When I go to the UserGrid test page
  Then I should see "Carlos"
  And  I should see "Castaneda"
  And  I should see "Taisha"
  And  I should see "Abelar"

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

@javascript
Scenario: Updating a record via "Edit in form"
  Given a user exists with first_name: "Carlos", last_name: "Castaneda"
  When I go to the UserGrid test page
  And I select first row in the grid
  And I press "Edit in form"
  And I fill in "First name:" with "Maxim"
  And I fill in "Last name:" with "Osminogov"
  And I press "OK"
  And I wait for the response from the server
  Then I should see "Maxim"
  And I should see "Osminogov"
  And a user should not exist with first_name: "Carlos"

@javascript
Scenario: Deleting a record
  Given a user exists with first_name: "Anton", last_name: "Chekhov"
  And a user exists with first_name: "Maxim", last_name: "Osminogov"
  When I go to the UserGrid test page
  And I select all rows in the grid
  And I press "Delete"
  Then I should see "Are you sure?"
  When I press "Yes"
  Then I should see "Deleted 2 record(s)"
  Then a user should not exist with first_name: "Anton"
  And a user should not exist with first_name: "Maxim"

@javascript
Scenario: Multi-editing records
  Given a user exists with first_name: "Carlos", last_name: "Castaneda"
  And a user exists with first_name: "Herman", last_name: "Hesse"
  When I go to the UserGrid test page
  And I select all rows in the grid
  And I press "Edit in form"
  And I fill in "First name:" with "Maxim"
  And I press "OK"
  Then I should see "Updated 2 records."
  And the following users should exist:
  | first_name | last_name |
  | Maxim | Castaneda |
  | Maxim | Hesse |
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
  And I wait for the response from the server
  Then a book should exist with title: "Lolita", exemplars: 100, digitized: true, author: that author

  When I press "Add in form"
  And I press "OK"
  And I wait for the response from the server
  Then 2 books should exist with title: "Lolita", exemplars: 100, digitized: true, author: that author

@javascript
Scenario: Inline editing
  Given a book exists with title: "Magus", exemplars: 100
  When I go to the BookGrid test page
  And I edit row 1 of the grid with title: "Collector", exemplars: 200
  And I press "Apply"
  And I wait for the response from the server
  Then the grid should have 0 modified records
  And a book should exist with title: "Collector", exemplars: 200
  But a book should not exist with title: "Magus"

@javascript
Scenario: Column filters
  Given the following books exist:
  | title               | exemplars | digitized | notes        |
  | Journey to Ixtlan   | 10        | true      | A must-read  |
  | Lolita              | 5         | false     | To read      |
  | Getting Things Done | 3         | true      | Productivity |
  When I go to the BookGrid test page
  And I enable filter on column "exemplars" with value "{gt:6}"
  And I sleep 1 second
  Then the grid should show 1 records

  When I clear all filters in the grid
  And I enable filter on column "notes" with value "'read'"
  And I sleep 1 second
  Then the grid should show 2 records

  When I clear all filters in the grid
  And I enable filter on column "digitized" with value "false"
  And I sleep 1 second
  Then the grid should show 1 records

  When I clear all filters in the grid
  And I enable filter on column "digitized" with value "true"
  And I sleep 1 second
  Then the grid should show 2 records

@javascript
Scenario: Inline editing of association
  Given an author exists with first_name: "Vladimir", last_name: "Nabokov"
  And a book exists with title: "Lolita", author: that author
  And an author exists with first_name: "Herman", last_name: "Hesse"
  When I go to the BookGrid test page
  And I expand combobox "author__name" in row 1 of the grid
  And I wait for the response from the server
  And I select "Hesse, Herman" in combobox "author__name" in row 1 of the grid
  And I edit row 1 of the grid with title: "Demian"
  And I stop editing the grid
  Then I should see "Hesse, Herman" within "#book_grid"

  When I press "Apply"
  And I wait for the response from the server
  Then a book should exist with title: "Demian", author: that author
  But a book should not exist with title: "Lolita"

@javascript
Scenario: Inline adding of records
  Given an author: "Nabokov" exists with first_name: "Vladimir", last_name: "Nabokov"
  And an author: "Hesse" exists with first_name: "Herman", last_name: "Hesse"

  When I go to the BookGrid test page
  And I press "Add"
  And I expand combobox "author__name" in row 1 of the grid
  And I wait for the response from the server
  And I select "Hesse, Herman" in combobox "author__name" in row 1 of the grid
  And I edit row 1 of the grid with title: "Demian"

  And I press "Add"
  And I expand combobox "author__name" in row 2 of the grid
  And I wait for the response from the server
  And I select "Nabokov, Vladimir" in combobox "author__name" in row 2 of the grid
  And I edit row 2 of the grid with title: "Lolita"

  And I stop editing the grid
  And I press "Apply"
  And I wait for the response from the server
  Then a book should exist with title: "Lolita", author: author "Nabokov"
  And a book should exist with title: "Demian", author: author "Hesse"

@javascript
Scenario: Inline adding of records in GridPanel with default values
  Given an author: "Nabokov" exists with first_name: "Vladimir", last_name: "Nabokov"
  And an author: "Hesse" exists with first_name: "Herman", last_name: "Hesse"

  When I go to the BookGridWithDefaultValues test page
  And I press "Add"
  And I expand combobox "author__last_name" in row 1 of the grid
  And I wait for the response from the server
  And I select "Hesse" in combobox "author__last_name" in row 1 of the grid
  And I edit row 1 of the grid with title: "Demian"

  And I stop editing the grid
  And I press "Apply"
  And I wait for the response from the server
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
  And I wait for the response from the server
  And I press "Search"
  And I press "Cancel"

  When I press "Load two"
  And I wait for the response from the server

  When I press "Load one"
  And I wait for the response from the server

  And I press "Search" within "#book_grid_loader__book_grid_one"
  And I wait for the response from the server
  And I press "Cancel" within "#book_grid_loader__book_grid_one__search_form"
  Then the "book_grid_loader__book_grid_one__search_form" component should be hidden
