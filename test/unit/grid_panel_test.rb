require 'test_helper'
require 'netzke-core'

class GridTest < ActiveSupport::TestCase

  test "api" do
    grid = Netzke::Grid.new(:name => 'grid', :model => 'Book', :columns => [:id, :title, :recent])
    grid_data = grid.get_data[:data]
    assert_equal(2, grid_data.count)

    # post
    res = grid.post_data("created_records" => [{:title => 'Lord of the Rings'}].to_nifty_json)
    assert_equal('Lord of the Rings', Book.last.title)

    # update
    grid.post_data("updated_records" => [{:id => Book.last.id, :title => 'Lolita'}].to_json)
    assert_equal('Lolita', Book.last.title)

    # get
    data = grid.get_data[:data]
    assert_equal(3, Book.count)
    assert_equal('Separate Reality', data[0][1]) # title of the first book
    assert_equal('The Journey to Ixtlan', data[1][1]) # title of the second book
    assert_equal('Yes', data[2][2]) # "recent" virtual column in the last book

    # delete all books
    res = grid.delete_data(:records => Book.all.map(&:id).netzke_json)
    assert_equal(nil, Book.first)

  end

  # test "normalize index" do
  #   grid = Netzke::Grid.new(:name => 'grid', :model => 'Book', :columns => [:id, :col0, {:name => :col1, :excluded => true}, :col2, {:name => :col3, :excluded => true}, :col4, :col5])
  #
  #   assert_equal(0, grid.normalize_index(0))
  #   assert_equal(1, grid.normalize_index(1))
  #   assert_equal(3, grid.normalize_index(2))
  #   assert_equal(5, grid.normalize_index(3))
  #   assert_equal(6, grid.normalize_index(4))
  # end

  test "default columns" do
    grid = Netzke::Grid.new(:model => "Book")

    assert_equal(7, grid.columns.size)
    # assert_equal({:name => "id", :type => :integer}, grid.columns.first)
  end


  # TODO: add tests with association column

end
