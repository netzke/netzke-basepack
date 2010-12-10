class SomeTabPanel < Netzke::Basepack::TabPanel
  config do
    {
      :active_tab => 0,
      :items => [:tab_one.component,:tab_two.component]
    }
  end

  component :tab_one, {
    :title => "First Tab",
    :class_name => "Basepack::Panel"
  }

  component :tab_two, {
    :title => "Second Tab",
    :class_name => "Basepack::Panel",
    :lazy_loading => true # Dynamically loaded when the tab gets open
  }

end
