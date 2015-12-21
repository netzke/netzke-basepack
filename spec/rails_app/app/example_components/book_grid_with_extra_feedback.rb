class BookGridWithExtraFeedback < Netzke::Grid::Base
  def configure(c)
    super
    c.model = Book
    c.default_filters = [{column: :last_read_at, value: {after: Date.parse("2011-01-01")}}]
  end

  # Override the get_data endpoint
  def get_data_endpoint(params)
    super.merge(:netzke_feedback => "Data loaded!")
  end
end
