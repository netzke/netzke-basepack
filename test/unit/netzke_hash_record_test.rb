require 'test_helper'
class NetzkeHashRecordTest < ActiveSupport::TestCase
  test "adding records" do
    ahr = NetzkeHashRecord
    ahr.widget = "my_widget"
    assert_equal({}, ahr.columns_hash)
    
    # add a record
    r = ahr.new
    r.save
    assert_equal(1, ahr.count)
    
    # delete all
    ahr.delete_all
    assert_equal(0, ahr.count)
    
    r = ahr.new({:name => 'One', :amount => 100, :approved => true})
    r.save
    r = ahr.new({:name => 'Two', :amount => 200, :approved => false})
    r.save
    
    assert_equal(2, ahr.count)
    assert_equal("One", ahr.first.name)
    assert_equal(100, ahr.first.amount)
    assert_equal(true, ahr.first.approved)
    assert_equal("Two", ahr.last.name)
    assert_equal(200, ahr.last.amount)
    assert_equal(false, ahr.last.approved)
    
    r = ahr.new({:name => 'Three', :amount => 300, :approved => true})
    r.save
    
    assert_equal(3, ahr.all.size) # add 3rd record
    
    # find
    assert_equal("One", ahr.find(1).name)
    assert_equal("Three", ahr.find(3).name)

    # deleting records
    ahr.delete([1,2])
    assert_equal(1, ahr.count)
    assert_equal("Three", ahr.last.name)
    assert_equal(1, ahr.last.id)
    
    # modifying records
    r = ahr.first
    r.name = "New name"
    r.save
    
    assert_equal("New name", ahr.first.name)
  end
  
  test "moving records" do
    ahr = NetzkeHashRecord
    ahr.widget = "my_widget"
    ahr.delete_all
    
    ahr.new({:name => "One"}).save
    ahr.new({:name => "Two"}).save
    ahr.new({:name => "Three"}).save
    
    ahr.move_item(0,1)
    assert_equal(%w{ Two One Three }, ahr.all.map(&:name))
    
    ahr.move_item(2,1)
    assert_equal(%w{ Two Three One }, ahr.all.map(&:name))
    
    ahr.move_item(0,2)
    assert_equal(%w{ Three One Two }, ahr.all.map(&:name))
    
    ahr.move_item(2,0)
    assert_equal(%w{ Two Three One }, ahr.all.map(&:name))
    
    ahr.save
    ahr.reload
    assert_equal(%w{ Two Three One }, ahr.all.map(&:name))
  end
end
