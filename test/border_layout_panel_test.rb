require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'test/unit/testcase'
require 'test/unit/autorunner'

require 'netzke-core'
require 'netzke/border_layout_panel'
require 'netzke/panel'
require 'netzke/properties_tool'
require 'netzke/grid_js_builder'
require 'netzke/grid_interface'
require 'netzke/grid'

class BorderLayoutPanelTest < ActiveSupport::TestCase
  test "dependencies" do
    widget = Netzke::BorderLayoutPanel.new(:name => 'Bla', :regions => {:center => {:widget_class_name => 'Panel'}, :east => {:widget_class_name => 'GridPanel'}})
    
    assert(%w{BorderLayoutPanel Panel GridPanel}.all?{|k| widget.dependencies.include?(k)})
    
    assert(widget.js_missing_code.index("Ext.componentCache['BorderLayoutPanel']"))
    assert(widget.js_missing_code.index("Ext.componentCache['Panel']"))
    assert(!widget.js_missing_code(%w{GridPanel Panel}).index("Ext.componentCache['GridPanel']"))
    assert(!widget.js_missing_code(%w{GridPanel Panel}).index("Ext.componentCache['Panel']"))
    assert(!widget.js_missing_code(%w{BorderLayoutPanel}).index("Ext.componentCache['BorderLayoutPanel']"))
    
  end
end