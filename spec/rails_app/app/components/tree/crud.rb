module Tree
  class Crud < Netzke::Basepack::Tree
    def configure(c)
      super

      c.model = "FileRecord"

      c.columns = [
        {name: :node_label, xtype: :treecolumn, flex: 1, read_only: true},
        {name: :file_name, flex: 1},
        {name: :size, flex: 1},
        {name: :leaf, flex: 1, type: :boolean, read_only: false},
      ]

      # Show all FileRecord records with parent_id of 'nil' as top-level records
      c.root = true

      # This hides the root
      c.root_visible = false
    end
  end
end
