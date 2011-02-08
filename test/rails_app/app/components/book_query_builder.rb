class BookQueryBuilder < Netzke::Basepack::QueryBuilder
  def default_config
    super.tap do |s|
      s[:model] = "Book"
      s[:auto_scroll] = true
    end
  end
end