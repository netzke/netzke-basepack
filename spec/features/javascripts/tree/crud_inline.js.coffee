describe 'Tree::CrudInline', ->
  it 'updates single record inline', ->
    wait().then ->
      selectLastRow()
      updateRecord file_name: 'New dir name'
    .then ->
      completeEditing()
      click button 'Apply'
      wait()
    .then ->
      wait()
    .then ->
      expect(valuesInColumn('file_name')).to.eql ['file1', 'file2', 'New dir name']
