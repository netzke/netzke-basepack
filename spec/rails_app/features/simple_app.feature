Feature: Basic application
  In order to value
  As a role
  I want feature

@javascript
Scenario: SimpleApp should load its components dynamically
  Given I am on the SomeSimpleApp test page
  When I click "Some accordion"
  Then I should see "Some Accordion"
  When I click "Book grid"
  Then I should see "Books"
  When I click "Some tab panel"
  Then I should see "Some Tab Panel"
