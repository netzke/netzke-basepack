# External dependencies
require 'active_support'
require 'netzke-core'

# ExtJS-related constants
require 'netzke/ext'
require 'netzke/active_record'

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


# FIXME: The following stylesheet inclusion doesn't *really* belong here, being widget-specific, 
# but I don't see any other solution for now. The problem is that these stylesheets come straight from
# Ext JS, having *relative* URLs to the images, which doesn't allow us to include them all together as those stylesheets 
# from Netzke.

# Used by FormPanel (file upload field)
Netzke::Base.config[:external_css] << "/extjs/examples/ux/fileuploadfield/css/fileuploadfield"

# Used by GridPanel
Netzke::Base.config[:external_css] << "/extjs/examples/ux/gridfilters/css/RangeMenu"
Netzke::Base.config[:external_css] << "/extjs/examples/ux/gridfilters/css/GridFilters"

if Netzke::Base.config[:with_icons].nil? && defined?(RAILS_ROOT)
  Netzke::Base.config[:with_icons] = File.exists?("#{RAILS_ROOT}/public#{Netzke::Base.config[:icons_uri]}")
end