class BookGridWithExtraFeedback < Netzke::Basepack::Grid
  model "Book"

  # Override the get_data endpoint
  def get_data_endpoint(params)
    super.merge(:nz_feedback => "Data loaded!")
  end
end
