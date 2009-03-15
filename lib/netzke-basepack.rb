# External dependencies
require 'netzke-core'
require 'searchlogic'

require 'netzke/ar_ext'

# Default boot config
# Netzke::Base.config.merge!({
#   :grid_panel => {:filters => true}
# }.recursive_merge(Object.const_defined?(:NETZKE_BOOT_CONFIG) ? Object.const_get(:NETZKE_BOOT_CONFIG) : {}))

%w{ models }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

# Make this plugin reloadable for easier development
ActiveSupport::Dependencies.load_once_paths.delete(File.join(File.dirname(__FILE__)))

# Include javascript & styles required by all basepack widgets. 
# These files will get loaded at the initial load of the framework (along with Ext and Netzke-core).
Netzke::Base.config[:javascripts] << "#{File.dirname(__FILE__)}/../javascripts/basepack.js"
Netzke::Base.config[:stylesheets] << "#{File.dirname(__FILE__)}/../stylesheets/basepack.css"
