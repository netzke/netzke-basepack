describe 'Grid::CrudInline', ->
  it 'shows association value on start editing the cell', ->
    wait().then ->
      selectFirstRow()
      click button 'Edit'
      expect(grid().getPlugin('celleditor').activeEditor.field.rawValue).to.eql "Herman Hesse"
