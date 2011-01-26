Feature: Validations in grid
  In order to value
  As a role
  I want feature

@javascript
Scenario: Multi-editing in grid with some records invalid
  Given an author exists with first_name: "Vladimir", last_name: "Nabokov"
  And a book exists with title: "Lolita", author: that author
  And an author exists with first_name: "Carlos", last_name: "Castaneda"
  And a book exists with title: "Luzhin Defence", author: that author
  When I go to the BookGridWithCustomColumns test page
