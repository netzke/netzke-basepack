class Grid::Filters < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = Book
  end

  def columns
    [ :title, :author__first_name, :author__year, :exemplars, :notes, :last_read_at, :digitized, :price,
      {
        name: :title_or_notes,
        getter: lambda {|foo| 'dummy' },
        filter_with: lambda {|rel, value, op| rel.where("title like ? or notes like ?", "%#{value}%", "%#{value}%")}
      },
      {
        name: :price_or_exemplars,
        getter: lambda {|rel| 5 },
        filter_with: lambda {|rel, value, op| rel.where("price > ? or exemplars > ?", value, value) }
      }
    ]
  end
end
