Feature: User grid
  In order to value
  As a role
  I want feature

@javascript
Scenario: UserGrid should not fail to open its windows 
  Given a user exists with first_name: "Carlos", last_name: "Castaneda"
  When I go to the UserGrid test page
  Then I should see "Carlos"
  And  I should see "Castaneda"
  And  I press "Add in form"
  Then I should see "Add User"
  

