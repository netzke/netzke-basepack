Feature: Grid panel filters
  In order to value
  As a role
  I want feature

Background:
  Given the following books exist:
  | title               | exemplars | digitized | notes        | last_read_at |
  | Journey to Ixtlan   | 10        | true      | A must-read  | 2011-01-10   |
  | Lolita              | 5         | false     | To read      | 2010-12-23   |
  | Getting Things Done | 3         | true      | Productivity | 2011-01-11   |

@javascript
Scenario: Numeric filter
  When I go to the BookGrid test page
  And I enable filter on column "exemplars" with value "{gt:6}"
  Then the grid should show 1 records

  When I clear all filters in the grid
  And I enable filter on column "exemplars" with value "{eq:5}"
  Then the grid should show 1 records

  When I clear all filters in the grid
  And I enable filter on column "exemplars" with value "{eq:6}"
  Then the grid should show 0 records

@javascript
Scenario: Text filter
  When I go to the BookGrid test page
  And I enable filter on column "notes" with value "'read'"
  Then the grid should show 2 records

@javascript
Scenario: Boolean filter
  When I go to the BookGrid test page
  And I enable filter on column "digitized" with value "false"
  Then the grid should show 1 records

  When I clear all filters in the grid
  And I enable filter on column "digitized" with value "true"
  Then the grid should show 2 records

@javascript
Scenario: Date filter
  When I go to the BookGrid test page
  And I enable filter on column "last_read_at" with value "{gt:'2011-01-11'}"
  And I wait 10 seconds
  Then the grid should show 2 records
