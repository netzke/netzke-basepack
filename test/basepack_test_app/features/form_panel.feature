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
  Scenario: A form should be rendered properly along with the data for the specified record
    Given a book exists with title: "Great Book", last_read_at: "2005-01-23"
    When I go to the BookFormWithDefaults test page
    Then the form should show title: "Great Book", last_read_at: "2005-01-23"

@javascript
Scenario: Editing the record
  Given a role exists with name: "musician"
  And a user exists with first_name: "Paul", last_name: "Bley", role: that role
  And a role exists with name: "painter"
  When I go to the UserForm test page
  And I fill in "First name:" with "Salvador"
  And I fill in "Last name:" with "Dali"
  And I expand combobox "Role name"
  And I select "painter" from combobox "Role name"
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

@javascript
Scenario: FormPanel should be functional without model provided
  Given I am on the FormWithoutModel test page
  When I fill in "Text field:" with "Some text"
  And I fill in "Number field:" with "42"
  And I expand combobox "Combobox field"
  And I select "Two" from combobox "Combobox field"
  And I check ext checkbox "Boolean field"
  And I press "Apply"

  Then I should see "Text field: Some text"
  And I should see "Number field: 42"
  And I should see "Boolean field: true"
  And I should see "Combobox field: 2"

@javascript
Scenario: Checkbox field should work properly
  Given an author exists with first_name: "Carlos"
  And a book exists with author: that author, digitized: false, exemplars: 2, title: "Some Title"
  When I go to the BookForm test page
  And I fill in "Exemplars:" with "4"
  And I check ext checkbox "Digitized"
  And I press "Apply"
  Then I should see "YES"
  And a book should exist with digitized: true, author: that author, exemplars: 4
  And a book should not exist with digitized: false, author: that author

@javascript
Scenario: Editing and immediately submitting the form
  Given an author exists with first_name: "Carlos", last_name: "Castaneda"
  And a book exists with title: "Journey to Ixtlan", author: that author
  When I go to the BookForm test page
  Then the form should show author__name: "Castaneda, Carlos"

  When I press "Apply"
  And I wait for the response from the server
  Then the form should show author__name: "Castaneda, Carlos"

# @javascript
# Scenario: Checkbox group for tags should work properly
#   Given a book exists with title: "Some Title"
#   When I go to the BookForm test page
#   And I check ext checkbox "recommend"
#   And I check ext checkbox "cool"
#   And I press "Apply"
#   And I wait for the response from the server
#   Then ext "cool" checkbox should be checked
#   And ext "recommend" checkbox should be checked
#   But ext "read" checkbox should not be checked
#   And a book should exist with tags: "cool,recommend"

@javascript
  Scenario: Validations
  Given a book exists with title: "Some Title"
  When I go to the BookForm test page
  And I fill in "Title:" with ""
  And I press "Apply"
  And I wait for the response from the server
  Then I should see "Title can't be blank"
  But I should not see "Success!"
  When I fill in "Title:" with "Not Blank"
  And I press "Apply"
  And I wait for the response from the server
  Then I should not see "Title can't be blank"
  But I should see "Success!"

@javascript
  Scenario: Setting date
    Given a book exists with title: "Some Title"
    When I go to the BookFormWithDefaults test page
    Then I fill in "Last read at:" with "2005-01-23"
    And I press "Apply"
    And I wait for the response from the server
    Then a book should exist with last_read_at: "2005-01-23"
