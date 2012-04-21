class SimpleAccordion < Netzke::Basepack::AccordionPanel
  component :simple_panel do |c|
    c.update_text = "Update for Panel Two"
    c.title = "Panel Two"
  end

  def items
    [{
      :html => "I'm a simple Ext.Panel",
      :title => "Panel One"
    },{
      :netzke_component => :simple_panel,
      :lazy_loading => true
    }]
  end
end
