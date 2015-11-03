module Tree
  class Scoped < Tree::Crud
    def configure(c)
      super
      c.scope = ->(scope) { scope.where("file_name LIKE 'file%' OR file_name LIKE 'dir3'") }
    end
  end
end
