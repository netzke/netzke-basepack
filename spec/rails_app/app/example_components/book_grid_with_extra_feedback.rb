class BookGridWithExtraFeedback < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = Book
    c.default_filters = [{column: :last_read_at, value: {after: Date.parse("2011-01-01")}}]
  end

  # Override the get_data endpoint
  def get_data_endpoint(params)
    super.merge(:nz_feedback => "Data loaded!")
  end
end
