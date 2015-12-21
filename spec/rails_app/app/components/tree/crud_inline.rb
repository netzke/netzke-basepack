module Tree
  class CrudInline < Crud
    def configure(c)
      super
      c.edit_inline = true
    end
  end
end
