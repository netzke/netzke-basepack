class GridWithLiveSearch < Netzke::Basepack::Grid
  plugin :grid_live_search do |c|
    c.klass = Netzke::Basepack::GridLiveSearch
    c.delay = 1 # our tests require immediate update
  end

  def configure(c)
    super
    c.model = "Book"
    c.tbar = [
      "Title:", {xtype: 'textfield', attr: :title, op: 'contains'},
      "Rating greater than:", {xtype: 'numberfield', attr: :rating, op: 'gt'},
      "Created on:", {xtype: 'datefield', attr: :created_at, op: 'eq'},
      '->',
      "Author first name:", {xtype: 'textfield', attr: :author__first_name, op: 'contains'},
      "Author last name:", {xtype: 'textfield', attr: :author__last_name, op: 'contains'},
    ]
  end
end
