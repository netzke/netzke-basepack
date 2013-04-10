class PanelWithGridWithDefaultFiltering < Netzke::Base

  js_configure do |c|
    c.layout = :border
  end

  component :center do |c|
    c.klass = Netzke::Basepack::Grid
    c.model = "Book"
    c.region = :center
    c.columns = [ :title, :author__first_name, :exemplars, :notes, :last_read_at, :digitized ]
    c.defaultFilters = [{column: :title, value: 'Brandstifter'}]
  end

  component :south do |c|
    c.klass = Netzke::Core::Panel
    c.height = 100
    c.collapsible = true
    c.region = :south
    c.split = true
  end

  def configure(c)
    super
    c.items = [
      :center,
      :south
    ]
  end
end
