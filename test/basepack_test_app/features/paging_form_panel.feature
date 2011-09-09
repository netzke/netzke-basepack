Feature: Paging form panel
  In order to value
  As a role
  I want feature

Background:
  Given the following books exist:
  | title               | exemplars | digitized | notes        | published_on | last_read_at |
  | Journey to Ixtlan   | 10        | true      | A must-read  | 2001-01-02   | 2011-01-02   |
  | Lolita              | 5         | false     | To read      | 1988-04-05   | 2011-03-04   |
  | Getting Things Done | 3         | true      | Productivity | 2005-06-07   | 2011-12-13   |

@javascript
Scenario: Paging through records
  When I go to the BookPagingFormPanel test page
  Then I should see "Journey to Ixtlan"

  When I go forward one page
  And  I wait for the response from the server
  Then the form should show title: "Lolita"

  When I go forward one page
  And  I wait for the response from the server
  Then the form should show title: "Getting Things Done"

@javascript
Scenario: Searching
  When I go to the BookPagingFormPanel test page
  And I press "Search"
  And I wait for the response from the server
  And I expand combobox "undefined_attr"
  And I select "Exemplars" from combobox "undefined_attr"
  And I expand combobox "exemplars_operator"
  And I select "Less than" from combobox "exemplars_operator"
  And I fill in "exemplars_value" with "5"
  And I press "Search" within "#book_paging_form_panel__search_form"
  And I wait for the response from the server
  Then the form should show title: "Getting Things Done"

@javascript
Scenario: I must see total records value
  When I go to the BookPagingFormPanel test page
  Then I should see "of 3" within paging toolbar
