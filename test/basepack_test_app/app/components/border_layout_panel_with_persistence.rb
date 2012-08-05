class BorderLayoutPanelWithPersistence < Netzke::Basepack::BorderLayoutPanel
  items [
    {title: "Center", region: :center},
    {title: "West", region: :west, width: 200, split: true, collapsible: true},
    {title: "North", region: :north, height: 100, split: true, collapsible: true}
  ]

  def configure(c)
    super
    c.persistence = true
  end
end
