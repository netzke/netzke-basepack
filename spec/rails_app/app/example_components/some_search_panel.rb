class SomeSearchPanel < Netzke::Basepack::SearchPanel
  def configure(c)
    c.model = "Book"
    c.fields = [{name: "title", field_label: "Title"}]
  end
end
