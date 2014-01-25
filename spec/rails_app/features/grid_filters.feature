Feature: Grid panel filters
  In order to value
  As a role
  I want feature

Background:
  Given an author exists with first_name: "Vladimir", last_name: "Nabokov"
  And a book exists with author: that author, title: "Lolita", exemplars: 5, digitized: false, notes: "To read", last_read_at: "2010-12-23"

  And an author exists with first_name: "Carlos", last_name: "Castaneda"
  And a book exists with author: that author, title: "Journey to Ixtlan", exemplars: 10, digitized: true, notes: "A must-read", last_read_at: "2011-04-25"

  And an author exists with first_name: "David", last_name: "Allen"
  And a book exists with author: that author, title: "Getting Things Done", exemplars: 3, digitized: true, notes: "Productivity", last_read_at: "2011-04-26"

@javascript
Scenario: Numeric filter
  When I go to the BookGridFiltering test page
  And I enable filter on column "exemplars" with value "{gt:6}"
  Then the grid should show 1 records

  When I clear all filters in the grid
  And I enable filter on column "exemplars" with value "{eq:5}"
  Then the grid should show 1 records

  When I clear all filters in the grid
  And I enable filter on column "exemplars" with value "{eq:6}"
  Then the grid should show 0 records


@javascript
Scenario: Boolean filter
  When I go to the BookGridFiltering test page
  And I enable filter on column "digitized" with value "false"
  Then the grid should show 1 records

  When I clear all filters in the grid
  And I enable filter on column "digitized" with value "true"
  Then the grid should show 2 records

@javascript
Scenario: Virtual Column Filter
  When I go to the GridWithCustomFilter test page
  # Just to initialize the filters. No assertion.
  And I enable filter on column "first_name" with value "'Vladimir'"

  When I clear all filters in the grid
  And I enable filter on column "name" with value "'lle'"
  Then the grid should show 1 records

  When I clear all filters in the grid
  And I enable filter on column "name" with value "'Carl'"
  Then the grid should show 1 records
