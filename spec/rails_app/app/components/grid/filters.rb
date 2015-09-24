class Grid::Filters < Netzke::Basepack::Grid
  model 'Book'

  def columns
    [ :title, :author__first_name, :author__year, :exemplars, :notes, :last_read_at, :digitized, :price,
      {
        name: :title_or_notes,
        getter: ->(foo) { 'dummy' },
        filter_with: ->(rel, value, op) {rel.where("title like ? or notes like ?", "%#{value}%", "%#{value}%")}
      },
      {
        name: :price_or_exemplars,
        getter: ->(rel) { 5 },
        filter_with: ->(rel, value, op) { rel.where("price > ? or exemplars > ?", value, value) }
      }
    ]
  end
end
