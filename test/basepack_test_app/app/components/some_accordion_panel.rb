class SomeAccordionPanel < Netzke::Basepack::AccordionPanel
  def configuration
    super.merge(
      :layout_config => {
         :animate => true,
       },
      :items => [:panel_one.component, :panel_two.component]
    )
  end

  component :panel_one, {
    :class_name => "Basepack::Panel",
    :title => "Panel One"
  }

  component :panel_two, {
    :class_name => "Basepack::Panel",
    :title => "Panel Two",
    :html => "Some html",
    :lazy_loading => true
  }
end