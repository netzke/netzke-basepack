class BookQueryBuilder < Netzke::Basepack::QueryBuilder
  def configure
    super

    config[:model] = "Book"
    config[:auto_scroll] = true
    config.fields = []
  end
end
