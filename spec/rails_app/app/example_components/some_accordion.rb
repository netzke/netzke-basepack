class SomeAccordion < Netzke::Basepack::Accordion
  # This component will be rendered immediately in the first tab
  #
  component :panel_zero do |c|
    c.klass = SimplePanel
    c.title = "Panel Zero"
  end

  # This component will be dynamically loaded on expanding the second accordion pane
  component :simple_panel do |c|
    c.update_text = "Update for Panel Two"
    c.title = "Panel Two"
    c.border = false
  end

  def configure(c)
    c.title = "Some Accordion"
    c.items = [
      :panel_zero,
      { :html => "I'm a simple Ext.Panel", :title => "Panel One" },
      :simple_panel
    ]
    super
  end
end
