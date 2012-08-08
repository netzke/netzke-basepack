class SimpleTabPanel < Netzke::Basepack::TabPanel
  js_configure do |c|
    c.active_tab = 0
  end

  component :simple_panel do |c|
    c.update_text = "Update for Panel Two"
    c.title = "Panel Two"
  end

  def configure(c)
    super

    c.items = [{
      :html => "I'm a simple Ext.Panel",
      :title => "Panel One"
    },{
      :netzke_component => :simple_panel,
      :lazy_loading => true
    }]
  end
end
