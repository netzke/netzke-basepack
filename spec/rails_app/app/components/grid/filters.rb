class Grid::Filters < Netzke::Basepack::Grid
  model 'Book'

  def columns
    [ :title, :author__first_name, :author__year, :author__prize_count, :exemplars, :notes, :last_read_at, :digitized,
      {
        name: :title_or_notes,
        getter: ->(foo) { 'dummy' },
        filter_with: ->(rel, value, op) {rel.where("title like ? or notes like ?", "%#{value}%", "%#{value}%")}
      }
    ]
  end
end
