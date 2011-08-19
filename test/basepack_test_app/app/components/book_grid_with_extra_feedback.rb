class BookGridWithExtraFeedback < Netzke::Basepack::GridPanel
  def default_config
    super.merge(
      :model => "Book"
    )
  end

  def get_data_endpoint(params)
    super.merge(:netzke_feedback => "Data loaded!")
  end
end