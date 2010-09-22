# External dependencies
require 'active_support'
require 'netzke-core'

path = File.dirname(__FILE__)
$LOAD_PATH << path

# Make component classes auto-loadable with help of ActiveSupport
ActiveSupport::Dependencies.autoload_paths << path

require 'netzke/active_record'

module Netzke
  autoload :Ext, 'ext'
end

# Make this plugin auto-reloadable for easier development
ActiveSupport::Dependencies.autoload_once_paths.delete(path)

# Make gem's models auto-loadable
%w{ models }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.autoload_paths << path
  ActiveSupport::Dependencies.autoload_once_paths.delete(path)
end

# Include javascript & styles required by all basepack components. 
# These files will get loaded at the initial load of the framework (along with Ext and Netzke-core).
Netzke::Component::Base.config[:javascripts] << "#{File.dirname(__FILE__)}/../javascripts/basepack.js"
Netzke::Component::Base.config[:stylesheets] << "#{File.dirname(__FILE__)}/../stylesheets/basepack.css"


# FIXME: The following stylesheet inclusion doesn't *really* belong here, being component-specific, 
# but I don't see any other solution for now. The problem is that these stylesheets come straight from
# Ext JS, having *relative* URLs to the images, which doesn't allow us to include them all together as those stylesheets 
# from Netzke.

# Used by FormPanel (file upload field)
# Netzke::Component::Base.config[:external_css] << "/extjs/examples/ux/fileuploadfield/css/fileuploadfield"

# Used by GridPanel
# Netzke::Component::Base.config[:external_css] << "/extjs/examples/ux/gridfilters/css/RangeMenu"
# Netzke::Component::Base.config[:external_css] << "/extjs/examples/ux/gridfilters/css/GridFilters"

# Detect icons
if Netzke::Component::Base.config[:with_icons].nil? && defined?(Rails)
  Netzke::Component::Base.config[:with_icons] = File.exists?("#{Rails.root}/public#{Netzke::Component::Base.config[:icons_uri]}")
end