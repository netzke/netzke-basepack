Feature: Components in view
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: Components configured in the view should render properly
    When I go to the "simple panel" view
    Then I should see "Simple Panel content"
    When I press "Update html"
    Then I should see "HTML received from server"
