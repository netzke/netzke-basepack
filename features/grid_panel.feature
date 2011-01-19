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
  And I press "Yes"
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
  Given I am on the BookGridWithDefaultValues test page
  When I press "Add in form"
  And I press "OK"
  And I sleep 1 second
  Then a book should exist with title: "Lolita", exemplars: 100

@javascript
Scenario: Inline editing
  Given a book exists with title: "Magus", exemplars: 100
  When I go to the BookGrid test page
  And I edit row 1 of the grid with title: "Collector", exemplars: 200
  And I press "Apply"
  And I sleep 1 second
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
