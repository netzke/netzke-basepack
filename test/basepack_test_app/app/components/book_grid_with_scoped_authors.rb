class BookGridWithScopedAuthors < Netzke::Basepack::GridPanel
  def configuration
    super.tap do |c|
      c[:model] = "Book"
      c[:columns] = [:title, {:name => :author__first_name, :scope => lambda{ |r| r.where(:first_name.matches => "%tom%") }}]
    end
  end
end