class BookPagingFormPanel < Netzke::Basepack::PagingFormPanel
  def default_config
    super.merge({
      :model => "Book",
      :scope => {:digitized => true},
      :mode => :lockable
    })
  end
end