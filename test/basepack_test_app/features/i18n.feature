Feature: I18n
  In order to value
  As a role
  I want feature

Scenario: A grid with localized column headers
  When I go to the "es" version of the BookGrid page
  Then I should see "Autor"
  And I should see "Creado en"
  But I should not see "Author"
  And I should not see "Created at"

Scenario: A form with localized field labels
  When I go to the "es" version of the BookForm page
  Then I should see "Autor"
  And I should see "En abundancia"
  But I should not see "Author"
  And I should not see "In abundance"
