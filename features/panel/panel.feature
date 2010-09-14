Feature: Panel
  In order to value
  As a role
  I want feature

  @selenium
  Scenario: Configuring a Panel widget in the view
    When I go to the Panel widget test page
    When I should see "Original HTML"
    When I press "Update html"
    Then I should see "HTML received from server"
  
  
  
  
