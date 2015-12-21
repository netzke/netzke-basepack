# WIP (broken)
class Tree::LiveSearch < Netzke::Tree::Base
  plugin :grid_live_search do |c|
    c.klass = Netzke::Basepack::GridLiveSearch
    c.delay = 100 # our tests require immediate update
  end

  def configure(c)
    super

    c.model = "FileRecord"

    c.columns = [
      {name: :node_label, xtype: :treecolumn, flex: 1, read_only: true},
      {name: :name, flex: 1},
      {name: :size, flex: 1},
      {name: :leaf, flex: 1, type: :boolean, read_only: false},
      {name: :file_size, flex: 1, type: :integer}
    ]

    # Show all FileRecord records with parent_id of 'nil' as top-level records
    c.root = true

    # This hides the root
    c.root_visible = false

    c.tbar = [
      "Name:", {xtype: 'textfield', attr: :name}
    ]
  end
end
