class Grid::WithSummary < Netzke::Grid::Base
  column :name do |c|
    c.summary_type = :count
    c.summary_renderer = f(:title_summary_renderer)
  end

  def configure(c)
    super
    c.model = 'Author'
    c.columns = [:name]
    c.paging = :none
    c.features = [{ ftype: 'summary', dock: :bottom }]
  end
end
