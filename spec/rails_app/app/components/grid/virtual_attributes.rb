class Grid::VirtualAttributes < Netzke::Basepack::Grid
  attribute :borrowed do |c|
    c.type = :integer
    c.setter = ->(record, value) { record.notes = "Borrowed to: #{value}" }
    c.getter = ->(record) { record.notes ? record.notes.sub("Borrowed to: ", "").to_i : 0 }
  end

  attribute :notes do |c|
    c.read_only = true # otherwise the values from the form will override whatever is set by :borrowed
  end

  def configure(c)
    super
    c.model = Book
    c.columns = [:title, :borrowed, :notes]
    c.edit_inline = true
  end
end
