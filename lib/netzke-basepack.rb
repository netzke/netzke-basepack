# External dependencies
require 'netzke-core'
require 'searchlogic'

require 'netzke/ar_ext'

%w{ models }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

Netzke::Base.config[:javascripts] << "#{File.dirname(__FILE__)}/../javascripts/basepack.js"

# Make this plugin reloadable for easier development
ActiveSupport::Dependencies.load_once_paths.delete(File.join(File.dirname(__FILE__)))
