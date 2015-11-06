class ItemPersistence < Netzke::Base
  include Netzke::Basepack::ItemPersistence

  client_class do |c|
    c.layout = :border
  end

  component :west do |c|
    c.klass = Netzke::Core::Panel
    c.width = 100
    c.collapsible = true
    c.region = :west
    c.split = true
  end

  def configure(c)
    super
    c.items = [
      :west,
      {region: :center, title: "An Ext panel"},

      # not that for a regular region (which is not a Netzke component), item_id has to be set to enable this region's persistence
      {region: :east, width: 200, split: true, title: "East Ext panel", item_id: :east},
      {region: :south, height: 100, split: true, title: "South Ext panel", item_id: :south, collapsible: true}
    ]
  end
end
