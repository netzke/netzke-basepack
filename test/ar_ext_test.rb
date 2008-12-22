require 'test_helper'

require 'netzke/ar_ext'

class ArExtTest < ActiveSupport::TestCase
  test "default column config" do
    cc = Book.default_column_config(:title)
    
    assert_equal("Title", cc[:label])
    assert_equal(:text_field, cc[:shows_as])

    cc = Book.default_column_config({:name => :amount, :label => 'AMOUNT'})
    
    assert_equal("AMOUNT", cc[:label])
    assert_equal(:number_field, cc[:shows_as])
  end
end

