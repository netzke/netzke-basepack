describe "UserGrid component", ->
  it "does not allow deleting a user with first name 'Admin'", (done)->
    wait ->
      selectAllRows grid('Users')
      click button 'Delete'
      click button 'Yes'
      wait ->
        expectToSee somewhere "Can't delete admins"
        done()
