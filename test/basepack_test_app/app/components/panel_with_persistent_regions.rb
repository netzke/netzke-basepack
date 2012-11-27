class PanelWithPersistentRegions < Netzke::Base
  include Netzke::Basepack::ItemPersistence

  js_configure do |c|
    c.layout = :border
  end

  component :west do |c|
    c.klass = Netzke::Core::Panel
    c.width = 100
    c.collapsible = true
    c.region = :west
    c.split = true
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
      :west,
      :south,
      {region: :center, title: "An Ext panel"},

      # not that for a regular region (which is not a Netzke component), item_id has to be set to enable this region's persistence
      {region: :east, width: 200, split: true, title: "Another Ext panel", item_id: :east}
    ]
  end
end
