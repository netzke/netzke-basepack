class SomeAccordion < Netzke::Basepack::AccordionPanel
  # This component will be dynamically loaded on expanding the second accordion pane
  component :simple_panel do |c|
    c.update_text = "Update for Panel Two"
    c.title = "Panel Two"
    c.border = false
    c.prevent_header = true
  end

  def configure(c)
    c.items = [
      { :html => "I'm a simple Ext.Panel", :title => "Panel One" },
      :simple_panel
    ]
    super
  end
end
