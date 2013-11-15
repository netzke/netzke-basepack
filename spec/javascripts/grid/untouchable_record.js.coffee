describe "Grid component with model that prevents deletion", ->
  it "does not allow deleting a book with title 'Untouchable'", (done)->
    wait ->
      selectAllRows grid('Books')
      click button 'Delete'
      click button 'Yes'
      wait ->
        expectToSee somewhere "Can't delete this book"
        done()
