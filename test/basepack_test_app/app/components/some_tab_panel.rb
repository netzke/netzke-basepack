class SomeTabPanel < Netzke::Basepack::TabPanel
  # This component will be dynamically loaded on expanding the second accordion pane
  component :simple_panel do |c|
    c.update_text = "Update for Panel Two"
    c.title = "Panel Two"
    c.prevent_header = true
    c.border = false

    # optionally, you can force a certain component to be eagerly loaded:
    # c.eager_loading = true
  end

  def configure(c)
    c.title = "Some Tab Panel"
    c.active_tab = 0

    c.items = [
      { :html => "I'm a simple Ext.Panel", :title => "Panel One" },
      :simple_panel
    ]
    super
  end
end
