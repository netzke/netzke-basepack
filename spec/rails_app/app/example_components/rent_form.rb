class RentForm < Netzke::Basepack::Form
  js_configure do |c|
    c.mixin
  end

  def configure(c)
    super
    c.model = "Rent"

    c.record = Rent.last

    c.items = [
      {
        id: "authorCombo",
        xtype: :combo,
        field_label: 'Author',
        store: Author.select([:id, :last_name]).map { |x| [x.id, x.last_name] }
      },
      {
        id: "bookCombo",
        xtype: :combo,
        field_label: 'Book',
        name: 'book_id',
        store: Book.select([:id, :title, :author_id]).map { |x| [x.id, x.title, x.author_id] }
      },
      :user__name
    ]
  end
end
