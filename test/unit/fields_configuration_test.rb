require 'test_helper'
require 'netzke-core'

class FieldsConfigurationTest < ActiveSupport::TestCase
  test "attributes configurator" do
    Netzke::Base.session[:netzke_user_id] = User.find_by_login("seller1").id
    
    NetzkeModelAttrList.update_list_for_current_authority("Book", [{:name => "title", :label => "Title for seller1", :hidden => false}, {:name => "recent", :label => "Recent", :hidden => true}])
    
    list = NetzkeModelAttrList.read_list("Book")
    assert_equal(["Title for seller1", false], [list[0][:label], list[0][:hidden]])
    
    Netzke::Base.masquerade_as(:role, Role.find_by_name("seller").id)
    list = NetzkeModelAttrList.read_list("Book")
    # assert_equal(["Title for seller1", false], [list[0][:label], list[0][:hidden]])
    
    puts "!!! list: #{list.inspect}\n"
  end
  
end
