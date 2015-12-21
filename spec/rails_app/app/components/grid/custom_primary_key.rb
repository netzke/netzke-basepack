class Grid::CustomPrimaryKey < Netzke::Grid::Base
  def configure(c)
    c.title = "Books (model with custom primary key)"
    c.model = "BookWithCustomPrimaryKey"
    c.columns = [:author__name, :title]
    c.paging = true
    c.edit_inline = true
    super
  end
end
