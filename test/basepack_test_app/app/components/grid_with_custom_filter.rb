class GridWithCustomFilter < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = "Author"
    c.columns = [
      :first_name,
      :last_name,
      {
        name: :name,
        filter_with: ->(rel, value, op) {rel.where("first_name like ? or last_name like ?", "%#{value}%", "%#{value}%")},
        sorting_scope: :sorted_by_name
      }
    ]
  end
end
