require 'test_helper'

require 'netzke/active_record/attributes'

class ActiveRecordBasepackTest < ActiveSupport::TestCase
  fixtures :cities, :countries, :continents

  # test "default column and field configs" do
  #   cc = Book.default_column_config(:title)
  #
  #   assert_equal("Title", cc[:label])
  #   assert_equal(:textfield, cc[:editor])
  #   assert(!cc[:height])
  #
  #   cc = Book.default_column_config({:name => :amount, :label => 'AMOUNT'})
  #
  #   assert_equal("AMOUNT", cc[:label])
  #   assert_equal(:numberfield, cc[:editor])
  #
  #   cc = Book.default_column_config(:genre_id)
  #   assert_equal("genre__name", cc[:name])
  #   assert_equal(:combobox, cc[:editor])
  #
  #   cc = Book.default_column_config(:genre__popular)
  #   assert_equal(:checkbox, cc[:editor])
  # end

  test "choices for column" do
    cities = City.netzke_combo_options_for("name")
    assert_equal(3, cities.size)
    assert(cities.include?('Cordoba') && cities.include?('Buenos Aires'))

    countries = City.netzke_combo_options_for("country__name")
    assert_equal(2, countries.size)
    assert(countries.include?('Spain') && countries.include?('Argentina'))

    continents = City.netzke_combo_options_for("country__continent__name")
    assert_equal(2, continents.size)
    assert(continents.include?('Europe') && continents.include?('South America'))

    cities = City.netzke_combo_options_for("name", "Co")
    assert_equal(2, cities.size)
    assert(cities.include?('Cordoba') && cities.include?('Concordia'))
  end

  test "to array" do
    Book.send(:include, ::Netzke::ActiveRecord::DataAccessor )
    b = Book.create({:title => 'Rayuela', :genre_id => 200, :amount => 1000})
    columns = [{:name => "recent"}, {:name => "title"}, {:name => "amount"}, {:name => "genre_id"}]
    assert_equal(['Yes', 'Rayuela', 1000, 200], b.to_array(columns))
  end

end

