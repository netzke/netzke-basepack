require 'test_helper'
require 'rubygems'
require 'netzke-core'

class TabPanelTest < ActiveSupport::TestCase
  
  test "active item" do
    tab_panel = Netzke::TabPanel.new(:items => [{
      :widget_class_name => "Panel"
    },{
      :widget_class_name => "Panel", :name => "second_panel", :active => true
    }])
        
    assert_equal(2, tab_panel.initial_aggregatees.keys.size)
    assert_equal("item0", tab_panel.aggregatees[:item0][:name])
    assert_equal("second_panel", tab_panel.aggregatees[:second_panel][:name])
    assert(tab_panel.aggregatees[:second_panel][:active])
    assert_equal("Panel", tab_panel.js_config[:second_panel_config][:widget_class_name])
  end

end
