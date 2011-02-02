Feature: Paging form panel
  In order to value
  As a role
  I want feature

@javascript
Scenario: Paging through records
  Given the following books exist:
  | title               |
  | Journey to Ixtlan   |
  | Lolita              |
  | Getting Things Done |

  When I go to the BookPagingFormPanel test page
  Then I should see "Journey to Ixtlan"

  When I go forward one page
  Then the form should show title: "Lolita"

  When I go forward one page
  Then the form should show title: "Getting Things Done"

@javascript
Scenario: Searching
  Given the following books exist:
  | title               | exemplars | digitized | notes        |
  | Journey to Ixtlan   | 10        | true      | A must-read  |
  | Lolita              | 5         | false     | To read      |
  | Getting Things Done | 3         | true      | Productivity |

  When I go to the BookPagingFormPanel test page
  And I press "Search"
  And I wait for the response from the server
  And I expand combobox "exemplars_operator"
  And I select "Less than" from combobox "exemplars_operator"
  And I fill in "exemplars_value" with "5"
  And I press "Search" within "#book_paging_form_panel__search_form"
  And I wait for the response from the server
  Then the form should show title: "Getting Things Done"