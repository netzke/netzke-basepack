require 'test_helper'
require 'rubygems'
require 'netzke-core'

class AccordionPanelTest < ActiveSupport::TestCase
  
  test "specifying items" do
    accordion = Netzke::AccordionPanel.new(:items => [{
      :widget_class_name => "Panel"
    },{
      :widget_class_name => "Panel", :name => "second_panel", :active => true
    }])
        
    assert_equal(2, accordion.initial_aggregatees.keys.size)
    assert_equal("item0", accordion.aggregatees[:item0][:name])
    assert_equal("second_panel", accordion.aggregatees[:second_panel][:name])
    assert_equal("Panel", accordion.js_config[:second_panel_config][:scoped_class_name])
  end

end
