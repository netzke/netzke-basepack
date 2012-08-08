class PanelWithPersistentRegions < Netzke::Base
  # enable persistence on items sizes and collapse-states
  include Netzke::Basepack::ItemsPersistence

  js_configure do |c|
    c.layout = :border
  end

  component :west do |c|
    c.klass = SimplePanel
    c.width = 100
    c.collapsible = true
    c.region = :west
    c.split = true
  end

  component :south do |c|
    c.klass = SimplePanel
    c.height = 100
    c.collapsible = true
    c.region = :south
    c.split = true
  end

  def configure(c)
    super
    c.items = [ :west, :south, {region: :center, title: "An Ext panel"} ]
  end
end
