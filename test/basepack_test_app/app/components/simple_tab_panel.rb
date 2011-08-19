class SimpleTabPanel < Netzke::Basepack::TabPanel
  config  :items => [{
            :html => "I'm a simple Ext.Panel",
            :title => "Panel One"
          },{
            :class_name => "SimplePanel",
            :update_text => "Update for Panel Two",
            :title => "Panel Two",
            :lazy_loading => true
          }]
end