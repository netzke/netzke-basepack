describe 'Grid::WithSummary component', ->
  it 'all data at once and shows summary', ->
    wait().then ->
      summaryNode = Ext.DomQuery.selectNode(".x-grid-row-summary td:first-child div")
      expect(Ext.get(summaryNode).getHtml()).to.eql "Total: 33"
