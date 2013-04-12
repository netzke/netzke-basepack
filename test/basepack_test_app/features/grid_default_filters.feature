Feature: Grid panel default filters

Background:
  Given an author exists with first_name: "Max", last_name: "Frisch"
  And a book exists with author: that author, title: "Biedermann und die Brandstifter", exemplars: 5, digitized: false, notes: "To read", last_read_at: "2010-12-23"

  And an author exists with first_name: "Friedrich", last_name: "Dürrenmatt"
  And a book exists with author: that author, title: "Die Panne", exemplars: 10, digitized: true, notes: "A must-read", last_read_at: "2011-04-25"

  And an author exists with first_name: "Douglas", last_name: "Adams"
  And a book exists with author: that author, title: "The Hitchhiker's Guide to the Galaxy", exemplars: 3, digitized: true, notes: "The Answer", last_read_at: "2012-04-26"

@javascript
Scenario: simple default filter
  When I go to the BookGridDefaultFiltering test page
  And I wait for response from server
  Then the grid should show 1 records

@javascript
Scenario: date default filter
  When I go to the BookGridDateDefaultFiltering test page
  And I wait for response from server
  Then the grid should show 2 records

@javascript
Scenario: default filter and manual filter
  When I go to the BookGridDateDefaultFiltering test page
  And I wait for response from server
  Then the grid should show 2 records
  When I enable filter on column "exemplars" with value "{gt:6}"
  Then the grid should show 1 records
  When I clear all filters in the grid
  And I reload the grid
  And I wait for response from server
  Then the grid should show 3 records

@javascript
Scenario: default filter injected by parent component
  When I go to the PanelWithGridWithDefaultFiltering test page
  And I wait for response from server
  Then the grid should show 1 records

