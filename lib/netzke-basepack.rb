# External dependencies
require 'active_support'
require 'netzke-core'

# ExtJS-related constants
require 'netzke/ext'

# Make widget classes auto-loadable with help of ActiveSupport
path = File.dirname(__FILE__)
ActiveSupport::Dependencies.load_paths << path

# Make this plugin auto-reloadable for easier development
ActiveSupport::Dependencies.load_once_paths.delete(path)

# Make gem's models auto-loadable
%w{ models }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

# Include javascript & styles required by all basepack widgets. 
# These files will get loaded at the initial load of the framework (along with Ext and Netzke-core).
Netzke::Base.config[:javascripts] << "#{File.dirname(__FILE__)}/../javascripts/basepack.js"
Netzke::Base.config[:stylesheets] << "#{File.dirname(__FILE__)}/../stylesheets/basepack.css"

# FIXME: doesn't belong here
Netzke::Base.config[:stylesheets] << Netzke::Base.config[:ext_location] + "/examples/ux/fileuploadfield/css/fileuploadfield.css" if Netzke::Base.config[:ext_location]