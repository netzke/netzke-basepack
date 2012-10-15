# Not used in automatic tests
class BookGridWithDefaults < Netzke::Basepack::GridPanel
  def default_config
    super.merge(model: 'Book')
  end
end
