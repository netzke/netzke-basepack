# $LOAD_PATH.unshift File.dirname(__FILE__)

# External dependencies
require 'netzke-core'

# require 'netzke/active_record/basepack'
require 'netzke/ext'

# Basic widgets (inherited from Netzke::Base)
basic_widgets = %w[ panel accordion_panel basic_app border_layout_panel tab_panel form_panel grid_panel tree_panel window wrapper ] 

# Widget's inheriting from basic widgets
complex_widgets = %w[ configuration_panel fields_configurator masquerade_selector property_editor search_panel table_editor ]

# Require
# (basic_widgets + complex_widgets).each do |w|
#   require "netzke/#{w}"
# end

# require "netzke/form_panel"

%w{ models }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

# Make this plugin reloadable at app restart for easier development
ActiveSupport::Dependencies.load_once_paths.delete(File.join(File.dirname(__FILE__)))

# Include javascript & styles required by all basepack widgets. 
# These files will get loaded at the initial load of the framework (along with Ext and Netzke-core).
Netzke::Base.config[:javascripts] << "#{File.dirname(__FILE__)}/../javascripts/basepack.js"
Netzke::Base.config[:stylesheets] << "#{File.dirname(__FILE__)}/../stylesheets/basepack.css"
Netzke::Base.config[:stylesheets] << Netzke::Base.config[:ext_location] + "/examples/ux/fileuploadfield/css/fileuploadfield.css" if Netzke::Base.config[:ext_location]