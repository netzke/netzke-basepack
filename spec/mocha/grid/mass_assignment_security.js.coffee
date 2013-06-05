describe 'Grid::MassAssignmentSecurity', ->
  it 'cannot update protected attribute', (done) ->
    wait ->
      selectFirstRow()
      updateRecord exemplars: 200, title: 'New title'
      completeEditing()
      click button 'Apply'
      wait ->
        wait ->
          record = grid().getStore().last()
          expect(record.get('exemplars')).to.eql 100
          expect(record.get('title')).to.eql 'New title'
          done()
