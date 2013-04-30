describe 'BookGrid test component', ->
  it 'gives a validation error when trying to add an invalid record', (done) ->
    wait ->
      click button 'Add'
      editLastRow {exemplars: 3}
      click button 'Apply'
      wait ->
        expectToSee anywhere "Title can't be blank"
        expect(grid('Books').getStore().getModifiedRecords().length).to.eql(1)
        editLastRow {title: 'Foo'}
        click button 'Apply'
        wait ->
          expect(grid('Books').getStore().getModifiedRecords().length).to.eql(0)
          done()
