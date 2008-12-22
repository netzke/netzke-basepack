require 'test_helper'

require 'netzke/properties_tool'
require 'netzke/container'
require 'netzke/accordion'
require 'netzke/grid'

require 'netzke/ar_ext'
require 'netzke/column'

class GridTest < ActiveSupport::TestCase
  
  test "interface" do
    grid = Netzke::Grid.new(:name => 'grid', :data_class_name => 'Book', :layout_manager => false, :columns => [:id, :title, :recent])

    # post
    grid.post_data(:created_records => [{:title => 'Lord of the Rings'}].to_json)
    assert_equal('Lord of the Rings', Book.first.title)

    grid.post_data(:updated_records => [{:id => Book.first.id, :title => 'Lolita'}].to_json)
    assert_equal('Lolita', Book.first.title)

    grid.post_data(:created_records => [{:title => 'Upanishad'}].to_json)
    
    # get
    data = grid.get_data
    assert_equal('Lolita', data[:data][0][1]) # title of the first book
    assert_equal('Yes', data[:data][1][2]) # "recent" virtual column in the second book

    # delete
    res = grid.delete_data(:records => [1,2].to_json)
    assert_equal(true, res[:success])
    assert_equal(nil, Book.first)
    
  end

  # TODO: add tests with association columns
  
end
