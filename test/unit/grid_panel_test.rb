require 'test_helper'
require 'netzke-core'

require 'netzke/plugins/configuration_tool'
require 'netzke/accordion_panel'

require 'netzke/grid_panel/grid_panel_api'
require 'netzke/grid_panel/grid_panel_js'
require 'netzke/grid_panel'

require 'netzke/active_record/basepack'

class GridPanelTest < ActiveSupport::TestCase
  
  test "api" do
    grid = Netzke::GridPanel.new(:name => 'grid', :model => 'Book', :columns => [:id, :title, :recent])

    # post
    res = grid.post_data("created_records" => [{:title => 'Lord of the Rings'}].to_nifty_json)
    assert_equal('Lord of the Rings', Book.first.title)

    grid.post_data("updated_records" => [{:id => Book.first.id, :title => 'Lolita'}].to_json)
    assert_equal('Lolita', Book.first.title)

    grid.post_data("created_records" => [{:title => 'Upanishad'}].to_json)
    
    # get
    data = grid.get_data
    assert_equal('Lolita', data[:data][0][1]) # title of the first book
    assert_equal('Yes', data[:data][1][2]) # "recent" virtual column in the second book

    # delete
    res = grid.delete_data(:records => [1,2].to_json)
    assert_equal(nil, Book.first)
    
  end
  
  test "normalize index" do
    grid = Netzke::GridPanel.new(:name => 'grid', :model => 'Book', :columns => [:id, :col0, {:name => :col1, :excluded => true}, :col2, {:name => :col3, :excluded => true}, :col4, :col5])
    
    assert_equal(0, grid.normalize_index(0))
    assert_equal(1, grid.normalize_index(1))
    assert_equal(3, grid.normalize_index(2))
    assert_equal(5, grid.normalize_index(3))
    assert_equal(6, grid.normalize_index(4))
  end
  
  # TODO: add tests with association column
  
end
