describe 'GridWithActionColumn component', ->
  it 'deletes a record when delete column action is clicked', (done) ->
    wait ->
      addRecords {title: 'Book 1'}, {title: 'Book 2'}, to: grid('Books'), submit: true
      wait ->
        expect(grid('Books').getStore().getCount()).to.eql 2
        click tool 'refresh' # HACK: this shouldn't be needed after wait(), but locating icon fails on the next step otherwise
        wait ->
          click icon 'Delete row'
          click button 'Yes'
          wait ->
            expect(grid('Books').getStore().getCount()).to.eql 1
            done()
