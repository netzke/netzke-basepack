class SimpleAccordion < Netzke::Basepack::AccordionPanel
  def config
    {
      :items => [{
        :title => "Panel One",
        :html => "Content of first panel",
      },{
        :title => "Panel Two",
        :html => "Content of second panel"
      }]
    }.deep_merge super
  end
end
