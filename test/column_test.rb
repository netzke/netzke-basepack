require 'test_helper'

require 'netzke/ar_ext'

ActiveRecord::Base.class_eval do
  include Netzke::ActiveRecordExtensions
end

require 'netzke/column'

class ColumnTest < ActiveSupport::TestCase
  test "default columns" do
    stub_widget = Object.new
    def stub_widget.config
      {:name => 'widget', :data_class_name => 'Book', :columns => [:title, {:name => :amount, :read_only => true}, :recent]}
    end
    
    columns = Netzke::Column.default_columns_for_widget(stub_widget)
    
    assert_equal(false, columns[0][:read_only])
    assert_equal(true, columns[1][:read_only])
    assert_equal("Amount", columns[1][:label])
    assert_equal("Recent", columns[2][:label])
    assert_equal(true, columns[2][:read_only]) # read_only specified in the model itself
    # puts "!!! columns: #{columns.inspect}"
  end
end
