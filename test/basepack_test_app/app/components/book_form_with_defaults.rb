class BookFormWithDefaults < Netzke::Basepack::FormPanel
  def configuration
    super.tap do |c|
      c[:model] = "Book"
      c[:record_id] = Book.first.id
    end
  end
end