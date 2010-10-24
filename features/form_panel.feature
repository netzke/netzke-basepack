Feature: Form panel
  In order to value
  As a role
  I want feature

Scenario: UserForm should be rendered properly along with the data for the first user
  Given a role exists with name: "writer"
  And a user exists with first_name: "Carlos", last_name: "Castaneda", role: that role
  When I go to the UserForm test page
  Then I should see "Carlos"
  And I should see "Castaneda"
  And I should see "writer"

@javascript
Scenario: Editing the record
  Given a role exists with name: "musician"
  And a user exists with first_name: "Paul", last_name: "Bley", role: that role
  And a role exists with name: "painter"
  When I go to the UserForm test page
  And I fill in "First name:" with "Salvador"
  And I fill in "Last name:" with "Dali"
  And I fill in "Role name:" with "painter"
  And I press "Apply"
  And I go to the UserForm test page
  Then I should see "Salvador"
  And I should see "Dali"
  And I should see "painter"
  
  But I should not see "Maxim"
  And I should not see "Osminogov"
  And I should not see "musician"
  
Scenario: UserFormWithDefaultFields should render properly
  Given a role exists with name: "writer"
  And a user exists with first_name: "Carlos", last_name: "Castaneda", role: that role
  When I go to the UserFormWithDefaultFields test page
  Then I should see "Carlos"
  And I should see "Castaneda"
  And I should see "writer"

