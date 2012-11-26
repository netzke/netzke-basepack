require 'test_helper'
require 'rubygems'
require 'netzke-core'

class AccordionTest < ActiveSupport::TestCase

  test "specifying items" do
    accordion = Netzke::Accordion.new(:items => [{
      :class_name => "Panel"
    },{
      :class_name => "Panel", :name => "second_panel", :active => true
    }])

    assert_equal(2, accordion.initial_components.keys.size)
    assert_equal("item0", accordion.components[:item0][:name])
    assert_equal("second_panel", accordion.components[:second_panel][:name])
    assert_equal("Panel", accordion.js_config[:second_panel_config][:scoped_class_name])
  end

end
