class Grid::LiveSearch < Netzke::Basepack::Grid
  plugin :grid_live_search do |c|
    c.klass = Netzke::Basepack::GridLiveSearch
    c.delay = 1 # our tests require immediate update
  end

  column :author__name do |c|
    c.filter_with = lambda {|rel, value, op| rel.where("authors.first_name like ? or authors.last_name like ?", "%#{value}%", "%#{value}%")}
  end

  column :title do |c|
    c.flex = 1
  end

  def configure(c)
    super
    c.model = "Book"
    c.columns = [:author__name, :title, :rating, :created_on]
    c.tbar = [
      "Author:", {xtype: 'textfield', attr: :author__name},
      "Title:", {xtype: 'textfield', attr: :title, op: 'contains'},
      "Rating greater than:", {xtype: 'numberfield', attr: :rating, op: 'gt'},
      "Created on:", {xtype: 'datefield', attr: :created_at, op: 'eq'},
      "Notes:", {xtype: 'textfield', attr: :notes, op: 'contains'}
    ]
  end
end
