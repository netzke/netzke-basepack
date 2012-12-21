class GridWithLfilter < Netzke::Basepack::Grid
  model "Author"
  def columns
    [
      :first_name,
      {name: :name, filter_with: lambda{|rel, value, op| rel.where("first_name like ? or last_name like ?", "%#{value}%", "%#{value}%")} }
    ]
  end
end
