class SomeAccordion < Netzke::Basepack::AccordionPanel
  # This component will be dynamically loaded on expanding the second accordion pane
  component :simple_panel do |c|
    c.update_text = "Update for Panel Two"
    c.title = "Panel Two"
    c.border = false
    c.header = false
  end

  def configure(c)
    c.title = "Some Accordion"
    c.items = [
      { :html => "I'm a simple Ext.Panel", :title => "Panel One" },
      :simple_panel
    ]
    super
  end
end
