module Tree
  class CrudInline < Crud
    def configure(c)
      super
      c.editing = :inline
    end
  end
end
