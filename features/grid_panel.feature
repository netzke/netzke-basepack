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
  Then the following users should exist:
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


