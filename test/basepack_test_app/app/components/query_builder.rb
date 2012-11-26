class QueryBuilder < Netzke::Basepack::GridLib::QueryBuilder
  def configure(c)
    super
    c.model = "Book"
    c.fields = [{name: :title, field_label: "Title"}, {name: :author__name, field_label: "Author"}, {name: :digitized, field_label: "Digitized"}]
  end
end
