module Tree
  # Currently only R from CRUD is implemented
  class Crud < Netzke::Basepack::Tree
    def configure(c)
      super

      c.model = "FileRecord"

      c.columns = [
        {name: :name, xtype: :treecolumn, flex: 1},
        {name: :file_size, flex: 1}
      ]

      # This would hide the root
      # c.root_visible = false
    end
  end
end
