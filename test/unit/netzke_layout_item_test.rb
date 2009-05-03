require 'test_helper'
class NetzkeLayoutItemTest < ActiveSupport::TestCase
  test "moving records" do
    nli = NetzkeLayoutItem
    nli.widget = "my_widget"
    nli.delete_all
    
    nli.new({:name => "One"}).save
    nli.new({:name => "Two"}).save
    nli.new({:name => "Three"}).save
    
    nli.move_item(0,1)
    assert_equal(%w{ Two One Three }, nli.all.map(&:name))
    
    nli.move_item(2,1)
    assert_equal(%w{ Two Three One }, nli.all.map(&:name))
    
    nli.move_item(0,2)
    assert_equal(%w{ Three One Two }, nli.all.map(&:name))
    
    nli.move_item(2,0)
    assert_equal(%w{ Two Three One }, nli.all.map(&:name))
    
    nli.save
    nli.reload
    assert_equal(%w{ Two Three One }, nli.all.map(&:name))
  end
end
