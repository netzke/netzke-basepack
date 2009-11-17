require 'test_helper'
require 'rubygems'
require 'netzke-core'

class HelperModelTest < ActiveSupport::TestCase
  
  test "reading/writing values" do
    Netzke::FormPanel.config.deep_merge!({
      :persistent_config => true,
      :ext_config => {
        :enable_config_tool => true
      },
    })
    form = Netzke::FormPanel.new(:data_class_name => "Book")
    Netzke::PropertyEditor::HelperModel.widget = form
    helper_model = Netzke::PropertyEditor::HelperModel.new
    
    assert(true, helper_model.ext_config__config_tool)
    
    assert(true, helper_model.persistent_config)

    assert(true, form.ext_config[:enable_config_tool])
    
    # now try to change the configuration
    helper_model.ext_config__config_tool = "false"
    # form = Netzke::FormPanel.new(:data_class_name => "Book")
    # assert(false, form.ext_config[:enable_config_tool]) # FIXME: make it work
  end

end
