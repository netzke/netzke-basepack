# require 'rubygems'
# require 'test_helper'
# 
# require 'netzke-core'
# require 'netzke/border_layout_panel'
# require 'netzke/panel'
# require 'netzke/properties_tool'
# require 'netzke/db_fields'
# require 'netzke/grid_panel'

class BorderLayoutPanelTest < ActiveSupport::TestCase
  # TODO: rethink the test
  # test "dependencies" do
  #   widget = Netzke::BorderLayoutPanel.new(:name => 'Bla', :regions => {:center => {:widget_class_name => 'Panel'}, :east => {:widget_class_name => 'GridPanel'}})
  #   
  #   assert(%w{BorderLayoutPanel Panel GridPanel}.all?{|k| widget.dependencies.include?(k)})
  #   
  #   assert(widget.js_missing_code.index("Ext.netzke.cache['BorderLayoutPanel']"))
  #   # assert(widget.js_missing_code.index("Ext.netzke.cache['Panel']"))
  #   assert(!widget.js_missing_code(%w{GridPanel Panel}).index("Ext.netzke.cache['GridPanel']"))
  #   # assert(!widget.js_missing_code(%w{GridPanel Panel}).index("Ext.netzke.cache['Panel']"))
  #   # assert(!widget.js_missing_code(%w{BorderLayoutPanel}).index("Ext.netzke.cache['BorderLayoutPanel']"))
  #   
  # end
end